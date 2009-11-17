//
//  TagsController.h
//  TodayInHistory
//
//  Created by Serg Bayda on 10/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagsController : UITableViewController {
	NSArray *tags;

}

-(id)initWithTags:(NSArray *)aTags;

@end
