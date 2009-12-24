//
//  TagsController.m
//  TodayInHistory
//
//  Created by Serg Bayda on 10/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.

#import "TagsController.h"
#import "BrowserViewController.h"
#import "Tag.h"
#import "RootViewController.h"

@implementation TagsController

@synthesize tableView;

-(id)initWithTags:(NSArray *)aTags eventName:(NSString *)aName
{
	self = [super init];
	tags = [aTags retain];
	name = [aName retain];	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	CGSize tlSize = [name sizeWithFont:textView.font constrainedToSize:CGSizeMake(320, 208)];
	CGRect textRect = textView.frame;
	textRect.size.height = tlSize.height + 30;
	textRect.size.width = 320;
	textView.frame = textRect;
	
	CGRect tableRect = self.tableView.frame;
	tableRect.origin.y = tlSize.height + 30;
	tableRect.size.height = (416 - (tlSize.height + 30));
	tableRect.size.width = 320;
	self.tableView.frame = tableRect;
	textView.text = name;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.tableView reloadData];
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
	return [tags count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Tags"; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.font = [UIFont systemFontOfSize:16];
	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
	cell.textLabel.numberOfLines = 2;
    
	Tag *curtag = [tags objectAtIndex:indexPath.row];
	cell.textLabel.text = curtag.tagname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Tag *curtag = [tags objectAtIndex:indexPath.row];
	NSURLRequest *requrl = [NSURLRequest requestWithURL:[NSURL URLWithString:curtag.url]];
	BrowserViewController *webcontroller = [[BrowserViewController alloc] init];
	[webcontroller navigateTo:requrl];
	[self.navigationController pushViewController:webcontroller animated:YES];
	[webcontroller release];
}

- (void)dealloc
{
	[tags release];
	[name release];
	[super dealloc];
}

@end

