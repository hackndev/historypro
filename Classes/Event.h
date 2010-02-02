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
	NSArray *tags;
	NSNumber *pk;

}

- (id)initWithName:(NSString *)aName
			  tags:(NSArray *)aTags;

- (id)initWithName:(NSString *)aName
			  tags:(NSArray *)aTags
			  pkID:(NSNumber *)aPk;

@property (readonly) NSString *name;
@property (readonly) NSArray *tags;
@property (readonly) NSUInteger yearsPassed;
@property (readonly) NSNumber *pk;

@end
