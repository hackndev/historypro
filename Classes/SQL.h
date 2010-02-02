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

-(void)addEvent:(Event *)aEvent;
-(void)removeFavoriteEvent:(NSNumber *)pk;
-(Event *)favoriteEvents;
+ (SQL *)sharedInstance;

@end
