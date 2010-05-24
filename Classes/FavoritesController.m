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
#import "FavTableCell.h"
#import "TIHAppDelegate.h"

@interface FavoritesController ()

@property (nonatomic, readwrite, retain) NSArray *favEvents;

@end


@implementation FavoritesController

@synthesize favEvents;

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
	self.favEvents = [[SQL sharedInstance] favoriteEvents];
	
	copyListOfItems = [[NSMutableArray alloc] init];
	copiedEvents = [[NSMutableArray alloc] init];
	
	self.tableView.tableHeaderView = searchBar;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	
	searching = NO;
	letUserSelectRow = YES;
	
	eventDate = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.tableView reloadData];
	
	NSArray *segments = [NSArray arrayWithObjects:@"Event date", @"Days left", nil];

	UISegmentedControl *segmentedCtrl = [[UISegmentedControl alloc] initWithItems:segments];
	segmentedCtrl.selectedSegmentIndex = 0;
	[segmentedCtrl addTarget:self action:@selector(detailChanged:) forControlEvents:UIControlEventValueChanged];
	[segmentedCtrl setSegmentedControlStyle:UISegmentedControlStyleBar];
	
	
	UIBarButtonItem *spanButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	UIBarButtonItem *segmentButton = [[[UIBarButtonItem alloc] initWithCustomView:segmentedCtrl] autorelease];
	[segmentedCtrl release];
	
	UIBarButtonItem *labelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Show" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	
	[self setToolbarItems:[NSArray arrayWithObjects:spanButton, labelButton, segmentButton, nil]];
	if ([favEvents count] > 0) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
	[self.navigationController setToolbarHidden:NO animated:NO];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.navigationController setToolbarHidden:YES animated:NO];
}

- (IBAction)detailChanged:(id)sender
{
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 0)
		[self eventDate];
	else
		[self daysLeft];
}

- (void)eventDate
{
	eventDate = YES;
	[self.tableView reloadData];
}

- (void)daysLeft
{
	eventDate = NO;
	[self.tableView reloadData];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
	searching = YES;
	letUserSelectRow = NO;
	self.tableView.scrollEnabled = NO;
	[self.tableView reloadData];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar {
    _searchBar.text=@"";
    
    [_searchBar setShowsCancelButton:NO animated:YES];
    [_searchBar resignFirstResponder];
    self.tableView.scrollEnabled = YES;
	letUserSelectRow = YES;
	searching = NO;
	
	[self.tableView reloadData];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	[copiedEvents release];
	[copyListOfItems release];
	self.favEvents = nil;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	
	[copyListOfItems removeAllObjects];
	[copiedEvents removeAllObjects];
	
	if([searchText length] > 0) {
		
		searching = YES;
		letUserSelectRow = YES;
		self.tableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		searching = NO;
		letUserSelectRow = NO;
		self.tableView.scrollEnabled = NO;
	}
	
	[self.tableView reloadData];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavTableCell";
    
    FavTableCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
		cell = [FavTableCell cellFromFactory:self];
		
	if(searching)
	{
		NSString *en = [copyListOfItems objectAtIndex:indexPath.row];
		cell.title = en;	
		cell.shown = YES;
		cell.date = [[copiedEvents objectAtIndex:indexPath.row] evDate];
		}
	else
	{
		if (eventDate)
		{
			cell.title = [[favEvents objectAtIndex:indexPath.row] name];
			cell.shown = YES;
			cell.date = [[favEvents objectAtIndex:indexPath.row] evDate];
			}
		else
		{
			cell.title = [[favEvents objectAtIndex:indexPath.row] name];
			cell.shown = YES;
			
			NSDateComponents *c = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
			NSInteger currentYear = [c year];
			
			NSString *parsingDate = [[[favEvents objectAtIndex:indexPath.row] evDate] stringByAppendingString:[NSString stringWithFormat:@", %d", currentYear]];
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterMediumStyle];
			NSDate *date = [formatter dateFromString:parsingDate];
			
			
			NSString *dateConv = [formatter stringFromDate:[NSDate date]];
			NSDate *curdate = [formatter dateFromString:dateConv];
			[formatter release];
			
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
			cell.date = timeLabel;
			
			}
		}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the managed object for the given index path
		NSNumber *i = [[favEvents objectAtIndex:indexPath.row] pk];
		[[SQL sharedInstance] removeFavoriteEvent:i];
		[favEvents release];
		favEvents = [[[SQL sharedInstance] favoriteEvents] retain];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

