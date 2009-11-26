//
//  NetState.h
//  TodayInHistory
//
//  Created by Serg Bayda on 11/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetState : NSObject
{
	unsigned int networkCounter;
}

+ (NetState *)sharedInstance;

- (void)startedNetworkAccess;
- (void)finishedNetworkAccess;

@end