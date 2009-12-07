//
//  Tag.m
//  TodayInHistory
//
//  Created by Serg Bayda on 10/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"


@implementation Tag

@synthesize tagname;
@synthesize url;

- (id)initWithTagname:(NSString *)aTagname
			  url:(NSString *)aUrl 
{
	self = [super init];
	if (nil != self) {
		tagname = [aTagname retain];
		url = [aUrl retain];
	}
	return self;
}

-(void)dealloc
{
	[tagname release];
	[url release];
	[super dealloc];
}


@end
