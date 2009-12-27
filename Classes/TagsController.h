//
//  TagsController.h
//  TodayInHistory
//
//  Created by Serg Bayda on 10/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet UITableView *tableView;
	IBOutlet UITextView *textView;
	NSArray *tags;
	NSString *name;
}

@property (readonly) UITableView *tableView;

- (id)initWithTags:(NSArray *)aTags eventName:(NSString *)aName;

@end
