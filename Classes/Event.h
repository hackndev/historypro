//
//  Event.h
//  TodayInHistory
//
//  Created by Serg Bayda on 10/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Event : NSObject
{
	NSString *name;
	NSDate *date;
	NSArray *tags;

}

- (id)initWithName:(NSString *)aName
			  date:(NSDate *)aDate
			  tags:(NSArray *)aTags;

@property (readonly) NSString *name;
@property (readonly) NSDate *date;
@property (readonly) NSArray *tags;

@end
