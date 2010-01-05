//
//  RootViewController.m
//  TodayInHistory
//
//  Created by Serg Bayda on 10/29/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RootViewController.h"
#import "TagsController.h"
#import "Server.h"
#import "Event.h"

@implementation RootViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(!self) return self;
	
	isLoaded = NO;
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(onEventsUpdated:)
	 name:@"server.events.updated"
	 object:nil];
	
	return self;
}

- (void)onEventsUpdated:(NSNotification *)unused
{
	NSLog(@"updating!");
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithTitle:@"SC"
											  style:UIBarButtonItemStylePlain
											  target:self
											  action:@selector(presentSheet)] autorelease];
	isLoaded = YES;
	[self.tableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:buttonIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
	
- (void) presentSheet
{	
	UIActionSheet *menu = [[[UIActionSheet alloc]
							initWithTitle:@"Section"
							delegate:self
							cancelButtonTitle:nil
							destructiveButtonTitle:nil
							otherButtonTitles:nil] autorelease];
	
	for(NSString *s in [[Server sharedInstance] valueForKeyPath:@"list.Title"])
		[menu addButtonWithTitle:s];
	menu.cancelButtonIndex=[[Server sharedInstance].list count];
	[menu addButtonWithTitle:@"Cancel"];
	[menu showInView:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	NSDate *date = [[[NSDate alloc] init] autorelease];
	//[formatter setLocale:[NSLocale currentLocale]];
	
	NSString *stringFromDate = [formatter stringFromDate:date];
	[formatter release];
	
	self.title = (@"%@", stringFromDate);
	
	[[Server sharedInstance] getEventsForDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{

}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if(isLoaded)
		return [[Server sharedInstance].list count];
	else
		return 1;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(isLoaded) {
		NSDictionary *dict = [[Server sharedInstance].list objectAtIndex:section];
		NSArray *eventCount = [dict objectForKey:@"Objects"];
		return [eventCount count];
	} else
		return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if(isLoaded) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		NSDictionary *dict = [[Server sharedInstance].list objectAtIndex:indexPath.section];
		NSArray *companies = [dict objectForKey:@"Objects"];
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.numberOfLines = 2;
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		//cell.textLabel.text = [[companies objectAtIndex:indexPath.row] name];
		int myInt = [[[companies objectAtIndex:indexPath.row] name] length];
		if (myInt > 70) {
			NSString *labelName = [[[companies objectAtIndex:indexPath.row] name] substringWithRange:NSMakeRange(0,65)];
			labelName = [labelName stringByAppendingString:@"..."];
			cell.textLabel.text = labelName;
		} else {
			cell.textLabel.text = [[companies objectAtIndex:indexPath.row] name];
		}
	} else {
		cell.textLabel.text = NSLocalizedString(@"Loading", @"Loading message");
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(isLoaded) {
		NSDictionary *dict = [[Server sharedInstance].list objectAtIndex:section];
		return [dict objectForKey:@"Title"];
	} else
		return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return isLoaded ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(!isLoaded)
		return;
	NSDictionary *dict = [[Server sharedInstance].list objectAtIndex:indexPath.section];
    NSArray *companies = [dict objectForKey:@"Objects"];
	TagsController *controller = [[TagsController alloc] initWithTags:[[companies objectAtIndex:indexPath.row] tags]
															eventName:[[companies objectAtIndex:indexPath.row] name]];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (void)dealloc
{
    [super dealloc];
}


@end

