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

- (id)initWithName:(NSString *)aName
			  tags:(NSArray *)aTags
{
	self = [super init];
	if (nil != self) {
		name = [aName retain];
		tags = [aTags retain];
	}
	return self;
}

- (void)dealloc
{
	[tags release];
	[name release];
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
