//
//  TIHAppDelegate.m
//  TodayInHistory
//
//  Created by Serg Bayda on 10/29/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "TIHAppDelegate.h"
#import "RootViewController.h"


@implementation TIHAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{    
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application
{

}


#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

