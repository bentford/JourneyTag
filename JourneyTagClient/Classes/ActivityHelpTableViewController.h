//
//  LevelHelpTableViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 7/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTPayoutUtility.h"
#import "MyTestArrayOperation.h"

typedef enum {
    ActivityHelpLevel,
    ActivityHelpPayout 
} ActivityHelpMode;

@interface ActivityHelpTableViewController : UITableViewController {
    ActivityHelpMode myMode;
    NSArray *sectionTitleList;
    NSArray *detailSectionTitleList;

    NSInteger rowCount[2];
    
    JTPayoutUtility *payoutUtil;
    NSMutableArray *detailArray;
    int helpCellHeight;

}
- (id)initWithStyle:(UITableViewStyle)style helpMode:(ActivityHelpMode)mode;
- (void)fillLevelArray;
- (void)fillPayoutArray;

@end
