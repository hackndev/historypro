//
//  FavTableCell.h
//  Today in history
//
//  Created by serg on 17.03.10.
//  Copyright 2010 Hack&Dev FSO. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FavTableCell : UITableViewCell {
	IBOutlet UILabel *_title;
	IBOutlet UILabel *_date;
}
@property (nonatomic, readwrite, retain) NSString *title;
@property (nonatomic, readwrite, retain) NSString *date;
@property (nonatomic, readwrite, assign) BOOL shown;

+ (FavTableCell *)cellFromFactory:(id)owner;

@end