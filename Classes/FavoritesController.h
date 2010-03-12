//
//  FavoritesController.h
//  TodayInHistory
//
//  Created by Farcaller on 19.01.10.
//  Copyright 2010 Codeneedle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FavoritesController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet UITableView *tableView;
	NSArray *favEvents;
	NSMutableArray *copyListOfItems;
	NSMutableArray *copiedEvents;
	IBOutlet UISearchBar *searchBar;
	BOOL searching;
	BOOL letUserSelectRow;
	UITableViewCell *nibLoadedCell;
}

@property (readonly) UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *nibLoadedCell;
- (void) searchTableView;

@end
