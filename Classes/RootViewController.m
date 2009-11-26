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
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"November 15";	
	
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[Server sharedInstance].events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	Event *e = [[Server sharedInstance].events objectAtIndex:indexPath.row];
	cell.textLabel.text = e.name;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Event *e = [[Server sharedInstance].events objectAtIndex:indexPath.row];
	TagsController *controller = [[TagsController alloc] initWithTags:e.tags eventName:e.name];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (void)dealloc
{
    [super dealloc];
}


@end

