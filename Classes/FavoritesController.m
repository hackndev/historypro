//
//  FavoritesController.m
//  TodayInHistory
//
//  Created by Farcaller on 19.01.10.
//  Copyright 2010 Codeneedle. All rights reserved.
//

#import "FavoritesController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "SQL.h"
#import "TagsController.h"



@implementation FavoritesController

@synthesize tableView;
@synthesize nibLoadedCell;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithTitle:@"Back"
											  style:UIBarButtonItemStylePlain
											  target:self
											  action:@selector(onFavoritesDone:)] autorelease];
	self.navigationItem.title = @"Favorites";
	favEvents = [[[SQL sharedInstance] favoriteEvents] retain];
	
	copyListOfItems = [[NSMutableArray alloc] init];
	copiedEvents = [[NSMutableArray alloc] init];
	
	tableView.tableHeaderView = searchBar;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	
	searching = NO;
	letUserSelectRow = YES;
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
	searching = YES;
	letUserSelectRow = NO;
	tableView.scrollEnabled = NO;
	[tableView reloadData];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar {
    _searchBar.text=@"";
    
    [_searchBar setShowsCancelButton:NO animated:YES];
    [_searchBar resignFirstResponder];
    tableView.scrollEnabled = YES;
	letUserSelectRow = YES;
	searching = NO;
	
	[tableView reloadData];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	
	[copyListOfItems removeAllObjects];
	[copiedEvents removeAllObjects];
	
	if([searchText length] > 0) {
		
		searching = YES;
		letUserSelectRow = YES;
		tableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		searching = NO;
		letUserSelectRow = NO;
		tableView.scrollEnabled = NO;
	}
	
	[tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	[self searchTableView];
}

- (void) searchTableView {
	
	NSString *searchText = searchBar.text;
	NSMutableArray *searchArray = [[NSMutableArray alloc] init];
	
	[searchArray addObjectsFromArray:favEvents];
	
	for (Event *sTemp in searchArray)
	{
		NSRange titleResultsRange = [sTemp.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0) {
			[copyListOfItems addObject:sTemp.name];
			[copiedEvents addObject:sTemp];
		}
	}
	
	[searchArray release];
	searchArray = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (searching)
		return [copyListOfItems count];
	else {
		return [favEvents count];
	}
}
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"FavTableCell" owner:self options:NULL];
		cell = nibLoadedCell;
    }
	
	if(searching)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//		
//		cell.textLabel.font = [UIFont systemFontOfSize:14];
//		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
//		cell.textLabel.numberOfLines = 2;
//		cell.textLabel.textAlignment = UITextAlignmentLeft;
		NSString *en = [copyListOfItems objectAtIndex:indexPath.row];
//		int myInt = [en length];
//		if (myInt > 70) {
//			NSString *labelName = [en substringWithRange:NSMakeRange(0,65)];
//			labelName = [labelName stringByAppendingString:@"..."];
			UILabel *eventLabel = (UILabel*) [cell viewWithTag:2];
			eventLabel.text = en;
			UILabel *dateLabel = (UILabel*) [cell viewWithTag:1];
			dateLabel.text = [[copiedEvents objectAtIndex:indexPath.row] evDate];
	//	} else {
//			UILabel *titleLabel = (UILabel*) [cell viewWithTag:2];
//			titleLabel.text = en;
//			UILabel *dateLabel = (UILabel*) [cell viewWithTag:1];
//			dateLabel.text = stringFromDate;
//		}
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//		
//		cell.textLabel.font = [UIFont systemFontOfSize:14];
//		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
//		cell.textLabel.numberOfLines = 2;
//		cell.textLabel.textAlignment = UITextAlignmentLeft;
		NSString *en = [[favEvents objectAtIndex:indexPath.row] name];
		//int myInt = [en length];
//		if (myInt > 70) {
//			NSString *labelName = [en substringWithRange:NSMakeRange(0,65)];
//			labelName = [labelName stringByAppendingString:@"..."];
			UILabel *titleLabel = (UILabel*) [cell viewWithTag:2];
			titleLabel.text = en;
			UILabel *dateLabel = (UILabel*) [cell viewWithTag:1];
			dateLabel.text = [[favEvents objectAtIndex:indexPath.row] evDate];
	//	} else {
//			UILabel *titleLabel = (UILabel*) [cell viewWithTag:2];
//			titleLabel.text = en;
//			UILabel *dateLabel = (UILabel*) [cell viewWithTag:1];
//			dateLabel.text = stringFromDate;
//		}
	}

    return cell;
}

- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the managed object for the given index path
		NSNumber *i = [[favEvents objectAtIndex:indexPath.row] pk];
		[[SQL sharedInstance] removeFavoriteEvent:i];
		[favEvents release];
		favEvents = [[[SQL sharedInstance] favoriteEvents] retain];
		
		[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(searching) {
		TagsController *controller = [[TagsController alloc] initWithEvent:[copiedEvents objectAtIndex:indexPath.row]];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
	else {
		TagsController *controller = [[TagsController alloc] initWithEvent:[favEvents objectAtIndex:indexPath.row]];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
}
- (void)onFavoritesDone:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
	[favEvents release];
	[super dealloc];
}


@end

