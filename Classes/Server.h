//
//  Server.h
//  TodayInHistory
//
//  Created by Serg Bayda on 10/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Server : NSObject {
	NSMutableArray *_events;

}
@property (readonly) NSArray *events;

+ (Server *)sharedInstance;
- (void)getEventsForDate:(NSDate *)date;

@end
