//
//  BrowserViewController.m
//  TodayInHistory
//
//  Created by Farcaller on 29.09.09.
//  Copyright 2009 Hack&Dev Team. All rights reserved.
//

#import "BrowserViewController.h"
#import "NetState.h"

@implementation BrowserViewController

@synthesize viewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)navigateTo:(NSURLRequest *)request
{
	[self loadView];
	[webView loadRequest:request];
}

/*- (IBAction)close:(id)unused
{
	[viewController dismissModalViewControllerAnimated:YES];
	NSLog(@"DissMissModal");
}
*/

- (IBAction)back:(id)unused
{
	[webView goBack];
	NSLog(@"go back");
}

- (IBAction)forward:(id)unused
{
	[webView goForward];
		NSLog(@"go forward");
}

- (IBAction)stopReload:(id)unused
{
	if(isStop) {
		[webView stopLoading];
	} else {
		[webView reload];
	}
	isStop != isStop;
}

- (IBAction)openSafari:(id)unused
{
	NSURL *u = webView.request.URL; 
	[[UIApplication sharedApplication] openURL:u];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	isStop = YES;
	[[NetState sharedInstance] startedNetworkAccess];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	isStop = NO;
	[[NetState sharedInstance] finishedNetworkAccess];
}


@end
