//
//  Server.m
//  TodayInHistory
//
//  Created by Serg Bayda on 10/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Server.h"
#import "Event.h"
#import "Tag.h"
#import "DDXML+HTML.h"
#import "NSThread+PLBlocks.h"

@interface Server (PrivateAPI)

- (void)_fetchURL:(NSURL *)url caching:(BOOL)useCache invoking:(DataBlock)block;
- (NSData *)_fetchURL:(NSURL *)url caching:(BOOL)useCache;
- (BOOL)_parseData:(NSData *)htmlData forDate:(NSDate *)evDate;

@end


@implementation Server

@synthesize events = _events;
@synthesize list = _list;

- (id)init
{
	self = [super init];
	if(!self) return self;
	
	_events = [[NSMutableArray alloc] init];
	_list = [[NSMutableArray alloc] init];
	failed = NO;
	
	return self;
}

+ (Server *)sharedInstance
{
	static Server *server = nil;
	if(!server) {
		server = [[Server alloc] init];
	}
	return server;
}

/// Threaded wrapper for url fetcher
- (void)_fetchURL:(NSURL *)url caching:(BOOL)useCache invoking:(DataBlock)block
{
	DataBlock b = [block copy]; // copy it from stack to heap
	[NSThread pl_performBlockOnNewThread:^{
		NSData *htmlData = [[self _fetchURL:url caching:useCache] retain];
		
		[[NSThread mainThread] pl_performBlock:^{
			// this will run on main thread again
			b([htmlData autorelease]);
			[b release];
		}];
	}];
}

- (NSData *)_fetchURL:(NSURL *)url caching:(BOOL)useCache
{
	NSData *htmlData = nil;
	if(!useCache) {
		htmlData = [[[NSData alloc] initWithContentsOfURL:url] autorelease];
		if(!htmlData)
			failed = YES;
		return htmlData;
	}
	NSDate *now = [NSDate date];
	NSDate *cached = [[NSUserDefaults standardUserDefaults] valueForKey:@"cacheDate"];
	NSLog(@"cached %@ vs. %@", [[cached description] substringToIndex:10], [[now description] substringToIndex:10]);
	if([[[now description] substringToIndex:10] isEqualToString:[[cached description] substringToIndex:10]]) {
		htmlData = [[NSUserDefaults standardUserDefaults] valueForKey:@"cacheData"];
		NSLog(@"Got %d bytes from cache", [htmlData length]);
	} else {
		htmlData = [[[NSData alloc] initWithContentsOfURL:url] autorelease];
		if(htmlData) {
			[[NSUserDefaults standardUserDefaults] setValue:htmlData forKey:@"cacheData"];
			[[NSUserDefaults standardUserDefaults] setValue:now forKey:@"cacheDate"];
			NSLog(@"Cached %d bytes", [htmlData length]);
		} else {
			failed = YES;
		}
	}
	return htmlData; // XXX: will return nil on error
}

- (void)getEventsForDate:(NSDate *)date invoking:(SimpleBlock)callback
{
	[self getEventsForDate:date caching:YES invoking:callback];
}

- (void)getEventsForDate:(NSDate *)date caching:(BOOL)useCache invoking:(SimpleBlock)callback
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSDate *curdate = [date retain];
	//NSDate *curdate = [NSDate dateWithString:@"2009-03-04 10:45:32 +0600"];
	[formatter setDateFormat:@"MMMM dd"];
	
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:usLocale];
	
	NSString *stringFromDate = [formatter stringFromDate:curdate];
	[formatter release];
	NSString *stringForRef = [stringFromDate stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	NSString *formattedString = [NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", stringForRef];
	NSURL *url = [NSURL URLWithString:formattedString];
	[self _fetchURL:url caching:useCache invoking:^(NSData *htmlData){
		// html
		[self _parseData:htmlData forDate:date]; // TODO: check for parser failure
		callback();
	}];
}

- (BOOL)_parseData:(NSData *)htmlData forDate:(NSDate *)evDate
{
	[_events release];
	_events = [[NSMutableArray alloc] init];
	[_list release];
	_list = [[NSMutableArray alloc] init];
	NSError *error = nil;
	DDXMLDocument *htmlDocument = [[DDXMLDocument alloc]
								   initWithHTMLData:htmlData
								   options:HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR
								   error:&error];
	if(error) {
		[htmlDocument release];
		return NO;
	}
	
	// xpath
	NSDictionary *sortedEvents = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSMutableArray array], @"Events",
								  [NSMutableArray array], @"Births",
								  [NSMutableArray array], @"Deaths",
								  nil];
	for(NSString *s in [sortedEvents allKeys]) {
		NSString *xpath = [NSString stringWithFormat:@"/html/body/div[@id='content']/div[@id='bodyContent']/h2/span[@id='%@']/parent::h2/following::ul[1]/li", s];
		NSArray *array = [htmlDocument nodesForXPath:xpath error:&error];
		
		for(DDXMLElement *lis in array) {
			NSMutableString *descr = [NSMutableString string];
			NSMutableArray *tags = [NSMutableArray array];
			for(DDXMLElement *e in [lis children]) {
				if([e kind] == DDXMLTextKind) {
					NSString *tempStr = [[e description] stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
					[descr appendString:tempStr];
				} else {
					if ([[e attributeForName:@"href"] description] != nil) {
						NSString *prehttp = @"http://en.wikipedia.org";
						NSString *tagLink = [prehttp stringByAppendingString:[[e attributeForName:@"href"] stringValue]];
						char chr = [[[e childAtIndex:0] description] characterAtIndex:0];
						if (chr == '<') {
							int myInt = [[[e childAtIndex:0] description] length];
							NSString *tagName = [[[e childAtIndex:0] description] substringWithRange:NSMakeRange(3,myInt-7)];
							tagName = [tagName stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
							[descr appendString:tagName];
							Tag *c = [[[Tag alloc] initWithTagname:tagName url:tagLink] autorelease];
							[tags addObject:c];
						} else {
							NSString *tagName = [[e childAtIndex:0] description];
							tagName = [tagName stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
							[descr appendString:tagName];
							Tag *c = [[[Tag alloc] initWithTagname:tagName url:tagLink] autorelease];
							[tags addObject:c];
						}
						
					} else {
						for (DDXMLElement *q in [e children]) {
							if([q kind] == DDXMLTextKind) {
								NSString *tempStr = [[q description] stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
								[descr appendString:tempStr];
							} else {
								if ([[q attributeForName:@"href"] description] != nil) {
									NSString *prehttp = @"http://en.wikipedia.org";
									NSString *tagLink = [prehttp stringByAppendingString:[[q attributeForName:@"href"] stringValue]];
									NSString *tagName = [[q childAtIndex:0] description];
									tagName = [tagName stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
									[descr appendString:tagName];
									Tag *c = [[[Tag alloc] initWithTagname:tagName url:tagLink] autorelease];
									[tags addObject:c];
								} else {
									for (DDXMLElement *w in [q children]) {
										if([w kind] == DDXMLTextKind) {
											NSString *tempStr = [[w description] stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
											[descr appendString:tempStr];
										} else {
											if ([[w attributeForName:@"href"] description] != nil) {
												NSString *prehttp = @"http://en.wikipedia.org";
												NSString *tagLink = [prehttp stringByAppendingString:[[w attributeForName:@"href"] stringValue]];
												NSString *tagName = [[w childAtIndex:0] description];
												tagName = [tagName stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
												[descr appendString:tagName];
												Tag *c = [[[Tag alloc] initWithTagname:tagName url:tagLink] autorelease];
												[tags addObject:c];
											}
										}
									}
								}
							}
						}
					}
				}
			}
			Event *n = [[[Event alloc] initWithName:descr tags:tags date:evDate] autorelease];
			[_events addObject:n];
			[[sortedEvents objectForKey:s] addObject:n];
		}
	}
	for(NSString *k in [NSArray arrayWithObjects:@"Events", @"Births", @"Deaths", nil]) {
		NSArray *v = [sortedEvents objectForKey:k];
		if([v count])
			[_list addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							  k, @"Title",
							  [NSArray arrayWithArray:v], @"Objects",
							  nil]];
	}
	return YES;
}

- (void)getEventsForDate:(NSDate *)date caching:(BOOL)useCache
{
	[self getEventsForDate:date caching:useCache invoking:^{
		[NSTimer scheduledTimerWithTimeInterval:0
										 target:self
									   selector:@selector(_onTimer:)
									   userInfo:[NSDictionary
												 dictionaryWithObject:[NSNumber numberWithBool:failed]
												 forKey:@"hasFailed"]
										repeats:NO];
	}];
}

- (void)getEventsForDate:(NSDate *)date
{
	[self getEventsForDate:date caching:YES];
}

- (void)_onTimer:(NSTimer *)timer
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"server.events.updated"
	 object:self
	 userInfo:[timer userInfo]];
}

@end
