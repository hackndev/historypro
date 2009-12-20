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

@implementation Server

@synthesize events = _events;
@synthesize list = _list;

- (id)init
{
	self = [super init];
	if(!self) return self;
	
	_events = [[NSMutableArray alloc] init];
	_list = [[NSMutableArray alloc] init];
	
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

- (void)getEventsForDate:(NSDate *)date
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSDate *curdate = [date retain];
	//NSDate *curdate = [NSDate dateWithString:@"2009-03-04 10:45:32 +0600"];
	[formatter setDateFormat:@"MMMM dd"];
	
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:usLocale];
	
	NSString *stringFromDate = [formatter stringFromDate:curdate];
	[formatter release];
	NSString *stringForRef = [stringFromDate stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	NSError *error = nil;
	NSString *formattedString = [NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", stringForRef];
	NSURL *url = [NSURL URLWithString:formattedString];
	
	//NSURL *testUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"March_1" ofType:@"html"] isDirectory:NO];
	
	NSData *htmlData = [[[NSData alloc] initWithContentsOfURL:url] autorelease];
	
	// html
	DDXMLDocument *htmlDocument = [[DDXMLDocument alloc]
								   initWithHTMLData:htmlData
								   options:HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR
								   error:&error
								   ];
	
	// xpath
	NSMutableArray *ArrEv = [[NSMutableArray alloc] init];
	NSMutableArray *ArrBi = [[NSMutableArray alloc] init];
	NSMutableArray *ArrDe = [[NSMutableArray alloc] init];
	for (int i=1; i < 4; i++) {
		NSString *xpath = [NSString stringWithFormat:@"/html/body/div[@id='globalWrapper']/div[@id='column-content']/div[@id='content']/div[@id='bodyContent']/ul[%d]/li", i];
		NSArray *array = [htmlDocument
						  nodesForXPath:xpath
						  error:&error
						  ];
		
		
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
			Event *n = [[[Event alloc] initWithName:descr date:[NSDate date] tags:tags] autorelease];
			[_events addObject:n];
			if (i == 1) {
				[ArrEv addObject:n];
			}
			if (i == 2) {
				[ArrBi addObject:n];
			}
			if (i == 3) {
				[ArrDe addObject:n];
			}
		}
		switch (i) {
			case 1:
				[_list addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								  @"Events", @"Title",
								  ArrEv, @"Objects",
								  nil]];
				break;
			case 2:
				[_list addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								  @"Birth", @"Title",
								  ArrBi, @"Objects",
								  nil]];
				break;
			case 3:
				[_list addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								  @"Death", @"Title",
								  ArrDe, @"Objects",
								  nil]];
				break;
		}
	}
	
#ifdef STUB
	[NSTimer scheduledTimerWithTimeInterval:1
									 target:self
								   selector:@selector(_onTimer:)
								   userInfo:nil
									repeats:NO];
#else
	#error NOT IMPLEMENTED
#endif
}

#ifdef STUB
- (void)_onTimer:(id)unused
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"server.events.updated" object:self];
}
#endif

@end
