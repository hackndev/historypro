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
#import "FavoritesController.h"
#import <QuartzCore/QuartzCore.h>

@implementation RootViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(!self) return self;
	
	isLoaded = NO;
	hasFailed = NO;
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(onEventsUpdated:)
	 name:@"server.events.updated"
	 object:nil];
	
	return self;
}

- (void)onEventsUpdated:(NSNotification *)notification
{
	NSLog(@"updating!");
	if(![[[notification userInfo] objectForKey:@"hasFailed"] boolValue]) {
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithBarButtonSystemItem:UIBarButtonSystemItemAction
												  target:self
												  action:@selector(presentSheet)] autorelease];
		isLoaded = YES;
	} else {
		hasFailed = YES;
	}
	[tableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.numberOfButtons-1) {
		NSLog(@"Cancel pressed");
	} else {
		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:buttonIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
}

- (void)presentSheet
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
	
	[picker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
	[picker setDate:[NSDate date]];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	NSDate *date = [[[NSDate alloc] init] autorelease];
	
	NSString *stringFromDate = [formatter stringFromDate:date];
	[formatter release];
	
	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(0, 0, 130, 36);
	
	[[btn layer] setCornerRadius:8.0f];
	[[btn layer] setMasksToBounds:YES];
	[[btn layer] setBorderWidth:1.0f];
	[[btn layer] setBorderColor:[[UIColor whiteColor] CGColor]];
	
	
	[btn setTitle:(@"%@", stringFromDate) forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.titleView = btn;
	
		
	[[Server sharedInstance] getEventsForDate:[NSDate date]];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
}

- (IBAction)titleClick:(id)sender
{
	[self _showPicker];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.leftBarButtonItem.enabled = NO;
	//self.navigationItem
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onFavoritesList:(id)sender
{
	FavoritesController *controller = [[FavoritesController alloc] initWithNibName:@"FavoritesController" bundle:nil];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller release];
	[navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self presentModalViewController:navController animated:YES];
}
#pragma mark -
#pragma mark Picker management
- (void)_showPicker
{
	CGRect frame = pickerView.frame;
	//CGRect tframe = tableView.frame;
	if(!_isPickerShown) {
		frame.origin.y = 0 + frame.size.height;
		pickerView.frame = frame;
		[UIView beginAnimations:@"moveInPicker" context:nil];
		frame.origin.y = 0;
		pickerView.frame = frame;
		//tframe.size.height -= 416;
//		tableView.frame = tframe;
		[UIView commitAnimations];
		_isPickerShown = YES;
	}
}

- (void)_hidePicker
{
	CGRect frame = pickerView.frame;
	//CGRect tframe = tableView.frame;
	if(_isPickerShown) {
		[UIView beginAnimations:@"moveOutPicker" context:nil];
		frame.origin.y = 0 + frame.size.height;
		pickerView.frame = frame;
		//tframe.size.height += 416;
//		tableView.frame = tframe;
		[UIView commitAnimations];
		
		_isPickerShown = NO;
	}
}

- (void)changeDate:(id)sender
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[btn setTitle:[formatter stringFromDate:[picker.date retain]] forState:UIControlStateNormal];
	[formatter release];
}

- (IBAction)chooseDate
{
	self.navigationItem.rightBarButtonItem.enabled = YES;
	self.navigationItem.leftBarButtonItem.enabled = YES;
	[self _hidePicker];
	isLoaded = NO;
	[tableView reloadData];
	[[Server sharedInstance] getEventsForDate:picker.date caching:NO];
}

#pragma mark -
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

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	static UITableViewCell *TextCell = nil;
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
		int myInt = [[[companies objectAtIndex:indexPath.row] name] length];
		if (myInt > 70) {
			NSString *labelName = [[[companies objectAtIndex:indexPath.row] name] substringWithRange:NSMakeRange(0,65)];
			labelName = [labelName stringByAppendingString:@"..."];
			cell.textLabel.text = labelName;
		} else {
			cell.textLabel.text = [[companies objectAtIndex:indexPath.row] name];
		}
		return cell;
	} else {
		if(!TextCell)
			TextCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextCell"];
			// TODO: possibly leaking
		if(!hasFailed) {
			TextCell.textLabel.text = NSLocalizedString(@"Loading", @"Loading message");
		} else {
			TextCell.textLabel.text = NSLocalizedString(@"Network connection failed", @"Fail message");
		}
		TextCell.textLabel.textAlignment = UITextAlignmentCenter;
		return TextCell;
	}
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

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	if(!isLoaded)
		return;
	NSDictionary *dict = [[Server sharedInstance].list objectAtIndex:indexPath.section];
    NSArray *companies = [dict objectForKey:@"Objects"];
	TagsController *controller = [[TagsController alloc] initWithEvent:[companies objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (void)dealloc
{
	[btn release];
    [super dealloc];
}


@end

