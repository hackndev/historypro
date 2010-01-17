//
//  BrowserViewController.m
//  TodayInHistory
//
//  Created by Farcaller on 29.09.09.
//  Copyright 2009 Hack&Dev Team. All rights reserved.
//

#import "BrowserViewController.h"
#import "NetState.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>

@implementation BrowserViewController

@synthesize viewController;

- (BOOL)connectedToNetwork
{
	// Create zero addy
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if (!didRetrieveFlags) {
		NSLog(@"Error. Could not recover network reachability flags");
		return NO;
	}
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	NSLog(@"Reachability test: %s", (isReachable && !needsConnection) ? "passed":"failed");
	return (isReachable && !needsConnection) ? YES : NO;
}

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
	NSString *dataLoading =	@"<html><head></head>"
							@"<body style='background-color: #ffffff;'><p>"
							@"<div style='font-family:\"Arial\";font-size:48px;text-align:center'><strong>Loading</strong></div>"
							@"</body></html>";
	
    NSString *daraError =	@"<html><head></head>"
							@"<body style='background-color: #ffffff;'><p>"
							@"<div style='font-family:\"Arial\";font-size:48px;text-align:center'><strong>No network connection available</strong></div>"
							@"</body></html>";
	
	[self loadView];
	[webView loadHTMLString:dataLoading baseURL:nil];
	if ([self connectedToNetwork]) {
		[webView loadRequest:request];
	} else {
		[webView loadHTMLString:daraError baseURL:nil];
	}

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
		[self webViewDidFinishLoad:webView];
		stopReloadButton.image = [UIImage imageNamed:@"01-refresh.png"];
	} else {
		[webView reload];
		stopReloadButton.image = [UIImage imageNamed:@"NavStop.png"];
	}
	isStop != isStop;
}

- (IBAction)openSafari:(id)unused
{
	NSURL *u = webView.request.URL; 
	UIActionSheet *s = [[UIActionSheet alloc]
						initWithTitle:[u description]
						delegate:self
						cancelButtonTitle:@"Cancel"
						destructiveButtonTitle:nil
						otherButtonTitles:@"Open in Safari", @"Send by E-mail", nil];
	[s showFromToolbar:toolbar];
	[s release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSURL *u = webView.request.URL;
	MFMailComposeViewController *mailController = nil;
	switch (buttonIndex) {
		case 0:
			[[UIApplication sharedApplication] openURL:u];
			break;
		case 1:
			mailController = [[MFMailComposeViewController alloc] init];
			mailController.mailComposeDelegate = self;
			[mailController setSubject:@"Did you know this?"];
			[mailController setMessageBody:[u description] isHTML:NO]; 
			[self presentModalViewController:mailController animated:YES];
			[mailController release];
			break;
		default:
			break;
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
	if (result == MFMailComposeResultSent) {
		NSLog(@"It's away!");
	}
	[self dismissModalViewControllerAnimated:YES];
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
