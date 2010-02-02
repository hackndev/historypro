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



@implementation FavoritesController

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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [favEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
	cell.textLabel.numberOfLines = 2;
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	NSString *en = [[favEvents objectAtIndex:indexPath.row] name];
	int myInt = [en length];
	if (myInt > 70) {
		NSString *labelName = [en substringWithRange:NSMakeRange(0,65)];
		labelName = [labelName stringByAppendingString:@"..."];
		cell.textLabel.text = labelName;
	} else {
		cell.textLabel.text = en;
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

