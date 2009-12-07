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

- (id)init
{
	self = [super init];
	if(!self) return self;
	
	_events = [[NSMutableArray alloc] init];
	
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
	NSError *error = nil;
	NSURL *url = [NSURL URLWithString:@"http://en.wikipedia.org/wiki/November_15"];
	NSData *htmlData = [[NSData alloc] initWithContentsOfURL:url];
	
	// html
	DDXMLDocument *htmlDocument = [[DDXMLDocument alloc]
								   initWithHTMLData:htmlData
								   options:HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR
								   error:&error
								   ];
	
	// xpath
	for (int i=1; i < 4; i++) {
		NSString *xpath = [NSString stringWithFormat:@"/html/body/div[@id='globalWrapper']/div[@id='column-content']/div[@id='content']/div[@id='bodyContent']/ul[%d]/li", i];
		NSLog(@"%@", xpath);
		NSArray *array = [htmlDocument
						  nodesForXPath:xpath
						  error:&error
						  ];
		
		
		for(DDXMLElement *lis in array) {
			NSMutableString *descr = [NSMutableString string];
			NSMutableArray *tags = [NSMutableArray array];
			for(DDXMLElement *e in [lis children]) {
				if([e kind] == DDXMLTextKind) {
					[descr appendString:[e description]];
				} else {
					if ([[e attributeForName:@"href"] description] != nil) {
						NSString *prehttp = @"http://en.wikipedia.org";
						NSString *tagLink = [prehttp stringByAppendingString:[[e attributeForName:@"href"] stringValue]];
						NSString *tagName = [[e childAtIndex:0] description];
						[descr appendString:tagName];
						Tag *c = [[Tag alloc] initWithTagname:tagName url:tagLink];
						[tags addObject:c];
					} else {
						for (DDXMLElement *q in [e children]) {
							if([q kind] == DDXMLTextKind) {
								[descr appendString:[q description]];
							} else {
								if ([[q attributeForName:@"href"] description] != nil) {
									NSString *prehttp = @"http://en.wikipedia.org";
									NSString *tagLink = [prehttp stringByAppendingString:[[e attributeForName:@"href"] stringValue]];
									NSString *tagName = [[q childAtIndex:0] description];
									[descr appendString:tagName];
									Tag *c = [[Tag alloc] initWithTagname:tagName url:tagLink];
									[tags addObject:c];
								}
							}
						}
					}
				}
			}
			Event *n = [[[Event alloc] initWithName:descr date:[NSDate date] tags:tags] autorelease];
			[_events addObject:n];
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
