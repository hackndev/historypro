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
	Event *e = [[Event alloc] initWithName:@"test" tags:[NSArray array]];
	
	STAssertEqualStrings(e.name, @"test", @"event name should be 'test', but was %@", e.name);
	STAssertEquals((int)[e.tags count], (int)0, @"event tags should be empty, but were %d", [e.tags count]);
	
	[e release];
}

@end
