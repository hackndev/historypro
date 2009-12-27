//
//  BrowserViewController.h
//  TodayInHistory
//
//  Created by Serg on 14.11.09.
//  Copyright 2009 Hack&Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BrowserViewController : UIViewController
{
	IBOutlet UIBarButtonItem *stopReloadButton;
	IBOutlet UIWebView *webView;

	UIViewController *viewController;
	
	BOOL isStop;
}

@property (nonatomic, readwrite, assign) UIViewController *viewController;

+ (BrowserViewController *)sharedInstance;

- (IBAction)back:(id)unused;
- (IBAction)forward:(id)unused;
- (IBAction)stopReload:(id)unused;
- (IBAction)openSafari:(id)unused;
- (void)navigateTo:(NSURLRequest *)request;

@end
