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
}

- (IBAction)forward:(id)unused
{
	[webView goForward];
}

- (IBAction)stopReload:(id)unused
{
	if(isStop) {
		[webView stopLoading];
	stopReloadButton.image = [UIImage imageNamed:@"NavStop.png"];

	} else {
		[webView reload];
	stopReloadButton.image = [UIImage imageNamed:@"01-refresh.png"];
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
	stopReloadButton.image = [UIImage imageNamed:@"01-refresh.png"];
	[[NetState sharedInstance] startedNetworkAccess];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	isStop = NO;
	stopReloadButton.image = [UIImage imageNamed:@"01-refresh.png"];
	[[NetState sharedInstance] finishedNetworkAccess];
}


@end
