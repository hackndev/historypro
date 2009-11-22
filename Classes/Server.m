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
	// TODO: fetch new events
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
	Tag *c = [[[Tag alloc] initWithTagname:@"Penda of Mercia" url:@"http://en.wikipedia.org/wiki/Penda_of_Mercia"] autorelease];
	Tag *b = [[[Tag alloc] initWithTagname:@"Oswiu of Northumbria" url:@"http://en.wikipedia.org/wiki/Oswiu_of_Northumbria"] autorelease];
	Tag *d = [[[Tag alloc] initWithTagname:@"Battle of Winwaed" url:@"http://en.wikipedia.org/wiki/Battle_of_Winwaed"] autorelease];
	NSArray *testarray = [[[NSArray alloc] initWithObjects:d, c, b, nil] autorelease];
	Event *e = [[[Event alloc] initWithName:@"655 – Battle of Winwaed: Penda of Mercia is defeated by Oswiu of Northumbria" date:[NSDate date] tags:testarray] autorelease];
	Tag *a = [[[Tag alloc] initWithTagname:@"Battle of Morgarten" url:@"http://en.wikipedia.org/wiki/Battle_of_Morgarten"] autorelease];
	Tag *z = [[[Tag alloc] initWithTagname:@"Schweizer Eidgenossenschaft" url:@"http://en.wikipedia.org/wiki/Swiss_Confederation"] autorelease];
	Tag *x = [[[Tag alloc] initWithTagname:@"Leopold I" url:@"http://en.wikipedia.org/wiki/Leopold_I,_Duke_of_Austria"] autorelease];
	NSArray *testarray1 = [[[NSArray alloc] initWithObjects:a, z, x, nil] autorelease];
	Event *w = [[[Event alloc] initWithName:@"1315 – Battle of Morgarten the Schweizer Eidgenossenschaft ambushes the army of Leopold I" date:[NSDate date] tags:testarray1] autorelease];
	
	[_events addObject:e];
	[_events addObject:w];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"server.events.updated" object:self];
}
#endif

@end
