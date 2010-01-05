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

+ (BrowserViewController *)sharedInstance
{
	static BrowserViewController *Instance = nil;
	@synchronized(self) {
		if(!Instance) {
			Instance = [[BrowserViewController alloc] init];
		}
	}
	return Instance;
}

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
	NSString *HTMLData =  @"<html><head></head>"
                          @"<body style='background-color: #ffffff;'>"
                          @"<div style='font-family:\"Arial\";font-size:48px;text-align:center'><strong>Loading</strong></div>"
						  @"</body></html>";
    
	[self loadView];
	[webView loadHTMLString:HTMLData baseURL:nil];
	[webView loadRequest:request];
}

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
	NSLog(@"Loading started");
	isStop = YES;
	stopReloadButton.image = [UIImage imageNamed:@"NavStop.png"];
	[[NetState sharedInstance] startedNetworkAccess];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"Loading stopped");
	isStop = NO;
	stopReloadButton.image = [UIImage imageNamed:@"01-refresh.png"];
	[[NetState sharedInstance] finishedNetworkAccess];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(webView.loading)
        [[NetState sharedInstance] finishedNetworkAccess];        
    [webView stopLoading];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
