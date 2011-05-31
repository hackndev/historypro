//
//  RootViewController.h
//  TodayInHistory
//
//  Created by Serg Bayda on 10/29/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "CoolButton.h"

@interface RootViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate>
{
	BOOL isLoaded;
	BOOL hasFailed;
	BOOL _isPickerShown;
	
	IBOutlet UIDatePicker *picker;
	IBOutlet UITableView *tableView;
	IBOutlet UIView *pickerView;
	
	CoolButton *cButton;
}

- (IBAction)onFavoritesList:(id)sender;
- (IBAction)titleClick:(id)sender;
- (IBAction)chooseDate;
- (void)_showPicker;
- (void)_hidePicker;

@end
