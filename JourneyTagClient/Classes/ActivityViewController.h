//
//  ActivityViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 9/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
// This controller might replace ActivityTableViewController due to needing a non-scrolling area
// on above the UITableView

#import <UIKit/UIKit.h>
#import "JTAccountService.h"

@interface ActivityViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    UITableView *myTableView;
    JTAccountService *accountService;
    
    NSArray *list;
    NSArray *labels;
    
    NSArray *sectionTitles;
    NSInteger carryScore;
    NSInteger photoScore;
    NSInteger arrivalScore;
}
- (void)setupDefaultTableData;
- (void) signIn:(id)sender;
- (void) refreshData;
- (void ) signOut:(id)sender;
- (void)didSignOut:(NSDictionary*)dict;
- (void)didFail:(ASIHTTPRequest*)request;

- (void) didGetAccountInfo:(NSDictionary*)dict;    
@end
