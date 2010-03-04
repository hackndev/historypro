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
#import "Event.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "SQL.h"

@implementation TagsController

@synthesize tableView;

-(id)initWithEvent:(Event *)e
{
	self = [super init];
	event = [e retain];
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSString *textViewName;
	textViewName = [event.name stringByAppendingString:[NSString stringWithFormat:@" (%d year%s ago)",
														event.yearsPassed,
														event.yearsPassed == 1 ? "" : "s"]];
	
	CGSize tlSize = [textViewName sizeWithFont:textView.font constrainedToSize:CGSizeMake(320, 208)];
	CGRect textRect = textView.frame;
	textRect.size.height = tlSize.height + 30;
	textRect.size.width = 320;
	textView.frame = textRect;
	
	CGRect tableRect = self.tableView.frame;
	tableRect.origin.y = tlSize.height + 30;
	tableRect.size.height = (416 - (tlSize.height + 30));
	tableRect.size.width = 320;
	self.tableView.frame = tableRect;
	
	textView.text = textViewName;

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	NSDate *date = [[[NSDate alloc] init] autorelease];
	//[formatter setLocale:[NSLocale currentLocale]];
	
	NSString *stringFromDate = [formatter stringFromDate:date];
	[formatter release];
	
	self.title = (@"%@", stringFromDate);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *destinationPath = [[paths objectAtIndex:0] stringByAppendingString:@"/tmp.db"];
	FMDatabase* db = [FMDatabase databaseWithPath:destinationPath];
	if (![db open]) {
		NSLog(@"Could not open db.");
	}
	BOOL buttonCheck = NO;
	FMResultSet *rs = [db executeQuery:@"select * from event where eventName=? LIMIT 1", event.name];
	buttonCheck = [rs next];
	[rs close]; 
	[db close];
	UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Fav" style:buttonCheck?UIBarButtonItemStyleDone:UIBarButtonItemStylePlain target:self action:@selector(addFav:)];
	self.navigationItem.rightBarButtonItem = btn;
	[btn release];
}

- (void)addFav:(id)sender
{
	SQL *sqlcontroller = [SQL sharedInstance];
	if (self.navigationItem.rightBarButtonItem.style == UIBarButtonItemStylePlain) {
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
		[sqlcontroller addEvent:event];
	} else {
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
		int i = 0;
		favEvents = [[[SQL sharedInstance] favoriteEvents] retain];
		for(Event *enumerator in favEvents)
		{	
			if ([enumerator.name isEqualToString:event.name]) {
				NSNumber *j = [[favEvents objectAtIndex:i] pk];
				[sqlcontroller removeFavoriteEvent:j];
			}
		i++;
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [event.tags count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Tags"; 
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.font = [UIFont systemFontOfSize:16];
	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
	cell.textLabel.numberOfLines = 2;
    
	Tag *curtag = [event.tags objectAtIndex:indexPath.row];
	cell.textLabel.text = curtag.tagname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Tag *curtag = [event.tags objectAtIndex:indexPath.row];
	NSURLRequest *requrl = [NSURLRequest requestWithURL:[NSURL URLWithString:curtag.url]];
	BrowserViewController *webcontroller = [BrowserViewController sharedInstance];
	[webcontroller navigateTo:requrl];
	webcontroller.title = curtag.tagname;
	[self.navigationController pushViewController:webcontroller animated:YES];
}

- (void)dealloc
{
	[event release];
	[super dealloc];
}

@end

