//
//  NetState.m
//  TodayInHistory
//
//  Created by Serg Bayda on 11/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NetState.h"

@implementation NetState

+ (NetState *)sharedInstance
{
	static NetState *State = nil;
	
	@synchronized(self) {
		if(State == nil)
			State = [[NetState alloc] init];
	}
	
	return State;
}

- (void)startedNetworkAccess
{
	@synchronized(self) {
		if(networkCounter == 0) {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		}
		++networkCounter;
	}
}

- (void)finishedNetworkAccess
{
	@synchronized(self) {
		if(networkCounter == 0) {
			NSLog(@"NetState: underlocking network counter!");
			return;
		}
		--networkCounter;
		if(networkCounter == 0) {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
	}	
}

@end
