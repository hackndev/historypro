//
//  Server.h
//  TodayInHistory
//
//  Created by Serg Bayda on 10/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SimpleBlock)();
typedef void (^DataBlock)(NSData *data);

@interface Server : NSObject
{
	NSMutableArray *_events;
	NSMutableArray *_list;

}
@property (readonly) NSArray *events;
@property (readonly) NSArray *list;

+ (Server *)sharedInstance;
- (void)getEventsForDate:(NSDate *)date invoking:(SimpleBlock)callback;
- (void)getEventsForDate:(NSDate *)date;

@end
