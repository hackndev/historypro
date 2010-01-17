//
//  BrowserViewController.h
//  TodayInHistory
//
//  Created by Serg on 14.11.09.
//  Copyright 2009 Hack&Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface BrowserViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
	IBOutlet UIBarButtonItem *stopReloadButton;
	IBOutlet UIBarButtonItem *openSafariButton;
	IBOutlet UIWebView *webView;
	IBOutlet UIToolbar *toolbar;

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

- (void)webViewDidFinishLoad:(UIWebView *)webView;

@end
