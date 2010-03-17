//
//  FavTableCell.m
//  Today in history
//
//  Created by serg on 17.03.10.
//  Copyright 2010 Hack&Dev FSO. All rights reserved.
//

#import "FavTableCell.h"


@implementation FavTableCell

+ (FavTableCell *)cellFromFactory:(id)owner
{
	NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"FavTableCell" owner:owner options:nil];
	FavTableCell *c = [objs objectAtIndex:[objs count]-1];
	return c;
}

- (NSString *)title
{
	return _title.text;
}

- (void)setTitle:(NSString *)t
{
	_title.text = t;
}

- (NSString *)date
{
	return _date.text;
}

- (void)setDate:(NSString *)t
{
	_date.text = t;
}

- (BOOL)shown
{
	return NO; // XXX: i don't care
}

- (void)setShown:(BOOL)s
{
	if(s)
		[_title setFont:[UIFont systemFontOfSize:17]];
	else
		[_title setFont:[UIFont boldSystemFontOfSize:17]];
}

- (void)dealloc
{
	[super dealloc];
}


@end