//
//  FavoritesController.h
//  TodayInHistory
//
//  Created by Farcaller on 19.01.10.
//  Copyright 2010 Codeneedle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FavoritesController : UITableViewController
{
	NSArray *favEvents;
	NSMutableArray *copyListOfItems;
	NSMutableArray *copiedEvents;
	IBOutlet UISearchBar *searchBar;
	
	BOOL searching;
	BOOL letUserSelectRow;
	BOOL eventDate;
}

- (void) searchTableView;

- (IBAction)detailChanged:(id)sender;
- (void)eventDate;
- (void)daysLeft;

@end
