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

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
//	UITableView *table = self.tableView;
	switch (buttonIndex) {
		case 0:
			NSLog(@"Events");
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
			break;
		case 1:
			NSLog(@"Birth");
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionNone animated:YES];
			break;
		case 2:
			NSLog(@"Death");
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionNone animated:YES];
			break;
		default:
			break;
	}
}
	
- (void) presentSheet
{
	UIActionSheet *menu = [[UIActionSheet alloc]
						   initWithTitle: @ "Section"
						   delegate:self
						   cancelButtonTitle:@ "Cancel"
						   destructiveButtonTitle:nil
						   otherButtonTitles:@ "Events", @"Birth", @"Death", nil];
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
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"SC"
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(presentSheet)] autorelease];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 88;
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
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
	cell.textLabel.numberOfLines = 5;
    cell.textLabel.text = [[companies objectAtIndex:indexPath.row] name];
    return cell;
	}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
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

