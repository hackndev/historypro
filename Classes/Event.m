//
//  Event.m
//  TodayInHistory
//
//  Created by Serg Bayda on 10/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Event.h"


@implementation Event

@synthesize name;
@synthesize tags;
@synthesize pk;
@synthesize evDate;
@synthesize date;

- (id)initWithName:(NSString *)aName
			  tags:(NSArray *)aTags
			  date:(NSDate *)aDate
{
	self = [super init];
	if (nil != self) {
		name = [aName retain];
		tags = [aTags retain];
		date = [aDate retain];
	}
	return self;
}

- (id)initWithName:(NSString *)aName tags:(NSArray *)aTags pkID:(NSNumber *)aPkID evDate:(NSDate *)aEvDate;
{
	self = [super init];
	if (nil != self) {
		name = [aName retain];
		tags = [aTags retain];
		pk = [aPkID retain];
		evDate = [aEvDate retain];
	}
	return self;
}

- (void)dealloc
{
	[date release];
	[tags release];
	[name release];
	[pk release];
	[evDate release];
	[super dealloc];
}

- (NSUInteger)yearsPassed
{
	NSDateComponents *c = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
	NSInteger currentYear = [c year];
	NSInteger eventYear = [name integerValue];
	
	NSRange r = [name rangeOfString:@" "];
	if(r.location != NSNotFound) {
		unichar ch = [name characterAtIndex:r.location+1];
		if(ch == 'B') {
			return currentYear + eventYear;
		} else {
			return currentYear - eventYear;
		}
	} else {
		return 0;
	}

}


@end
