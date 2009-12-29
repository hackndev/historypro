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
	NSArray *tags = [NSArray arrayWithObjects:@"tag1", @"tag2", @"tag1", nil];
	NSDate *dt = [NSDate date];
	Event *e = [[Event alloc] initWithName:@"test" date:dt tags:tags];
	
	STAssertEqualStrings(e.name, @"test", @"event name should be 'test', but was %@", e.name);
	STAssertEquals([e.tags count], 2, @"event tags sould be 'tag1', 'tag2', but were %@", e.tags);
	
	[e release];
}

@end
