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
#import "math.h"



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
	
	eventDate = YES;
}

- (IBAction)eventDate:(id)sender
{
	eventDate = YES;
	[tableView reloadData];
}

- (IBAction)daysLeft:(id)sender
{
	eventDate = NO;
	[tableView reloadData];
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
		NSString *en = [copyListOfItems objectAtIndex:indexPath.row];
		UILabel *eventLabel = (UILabel*) [cell viewWithTag:2];
		eventLabel.text = en;
		UILabel *dateLabel = (UILabel*) [cell viewWithTag:1];
		dateLabel.text = [[copiedEvents objectAtIndex:indexPath.row] evDate];
		}
	else
	{
		if (eventDate)
		{
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			NSString *en = [[favEvents objectAtIndex:indexPath.row] name];
			UILabel *titleLabel = (UILabel*) [cell viewWithTag:2];
			titleLabel.text = en;
			UILabel *dateLabel = (UILabel*) [cell viewWithTag:1];
			dateLabel.text = [[favEvents objectAtIndex:indexPath.row] evDate];
			}
		else
		{
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			NSString *en = [[favEvents objectAtIndex:indexPath.row] name];
			UILabel *titleLabel = (UILabel*) [cell viewWithTag:2];
			titleLabel.text = en;
			UILabel *dateLabel = (UILabel*) [cell viewWithTag:1];
			NSString *parsingDate = [[[favEvents objectAtIndex:indexPath.row] evDate] stringByAppendingString:@", 2010"];
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterMediumStyle];
			NSDate *date = [formatter dateFromString:parsingDate];
			NSString *dateConv = [formatter stringFromDate:[NSDate date]];
			NSDate *curdate = [formatter dateFromString:dateConv];
			float timeInterval = [date timeIntervalSinceDate:curdate];
			NSString *timeLabel;
			int daysInterval = (((abs(timeInterval)/60)/60)/24);
			if (timeInterval < 0) {
				switch (daysInterval) {
					case 0:
						timeLabel = @"Today!";
						break;
					case 1:
						timeLabel = @"1 day past";
						break;
					default:
						timeLabel = [NSString stringWithFormat:@"%d days past", daysInterval];
						break;
				}
			} else {
				switch (daysInterval) {
					case 0:
						timeLabel = @"Today!";
						break;
					case 1:
						timeLabel = @"1 day left";
						break;
					default:
						timeLabel = [NSString stringWithFormat:@"%d days left", daysInterval];
						break;
				}
				
			}
			dateLabel.text = timeLabel;
			
			}
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

