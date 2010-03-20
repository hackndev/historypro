//
//  TagsController.h
//  TodayInHistory
//
//  Created by Serg Bayda on 10/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface TagsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet UITableView *tableView;
	IBOutlet UITextView *textView;
	Event *event;
	NSArray *favEvents;
	UIToolbar *toolbar;
}

@property (readonly) UITableView *tableView;

- (id)initWithEvent:(Event *)e;
- (id)initWithEvent:(Event *)e unToolbar:(UIToolbar *)aToolbar;

@end
