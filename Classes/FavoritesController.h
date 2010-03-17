//
//  FavoritesController.h
//  TodayInHistory
//
//  Created by Farcaller on 19.01.10.
//  Copyright 2010 Codeneedle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FavoritesController : UITableViewController /*<UITableViewDelegate, UITableViewDataSource>*/
{
	//IBOutlet UITableView *customTableView;
	NSArray *favEvents;
	NSMutableArray *copyListOfItems;
	NSMutableArray *copiedEvents;
	IBOutlet UISearchBar *searchBar;
	BOOL searching;
	BOOL letUserSelectRow;
	BOOL eventDate;
}

//@property (nonatomic, readwrite, retain) UITableView *customTableView;
- (void) searchTableView;

- (IBAction)detailChanged:(id)sender;
- (IBAction)eventDate:(id)sender;
- (IBAction)daysLeft:(id)sender;

@end
