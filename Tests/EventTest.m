//
//  EventTest.m
//  TodayInHistory
//
//  Created by Farcaller on 29.12.09.
//  Copyright 2009 Codeneedle. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "Event.h"

@interface EventTest : GTMTestCase { }
@end


@implementation EventTest

- (void)testEventProperties
{
	NSDate *dt = [NSDate date];
	Event *e = [[Event alloc] initWithName:@"test" date:dt tags:[NSArray array]];
	
	STAssertEqualStrings(e.name, @"test", @"event name should be 'test', but was %@", e.name);
	STAssertEquals((int)[e.tags count], (int)0, @"event tags should be empty, but were %d", [e.tags count]);
	STAssertEquals(e.date, dt, @"event date sould be %@, but was %@", dt, e.date);
	
	[e release];
}

@end
