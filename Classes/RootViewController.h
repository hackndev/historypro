//
//  RootViewController.h
//  TodayInHistory
//
//  Created by Serg Bayda on 10/29/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@interface RootViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate>
{
	BOOL isLoaded;
	BOOL hasFailed;
	BOOL _isPickerShown;
	
	IBOutlet UIDatePicker *picker;
	IBOutlet UITableView *tableView;
	IBOutlet UIView *pickerView;
	
	UIButton *btn;
}

- (IBAction)onFavoritesList:(id)sender;
- (IBAction)titleClick:(id)sender;
- (IBAction)chooseDate;
- (void)_showPicker;
- (void)_hidePicker;

@end
