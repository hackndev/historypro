 //
//  SQL.h
//  TodayInHistory
//
//  Created by Serg Bayda on 1/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "Event.h"

//extern NSString *kID;
//extern NSString *kName;

@interface SQL : NSObject
{
	FMDatabase* db;
}

- (void)addEvent:(Event *)aEvent evDate:(NSDate *)aEvDate;
- (void)removeFavoriteEvent:(Event *)event;
- (BOOL)isEventFavorited:(Event *)event;
- (NSArray *)favoriteEvents;
+ (SQL *)sharedInstance;

@end
