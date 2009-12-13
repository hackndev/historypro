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
    return [[Server sharedInstance].list count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    NSDictionary *dict = [[Server sharedInstance].list objectAtIndex:section];
    NSArray *companies = [dict objectForKey:@"Objects"];
    return [companies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	NSDictionary *dict = [[Server sharedInstance].list objectAtIndex:indexPath.section];
    NSArray *companies = [dict objectForKey:@"Objects"];
    cell.textLabel.text = [[companies objectAtIndex:indexPath.row] name];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = [[Server sharedInstance].list objectAtIndex:section];
    return [dict objectForKey:@"Title"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

