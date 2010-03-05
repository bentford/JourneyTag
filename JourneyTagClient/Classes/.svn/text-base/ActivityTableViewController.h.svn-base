//
//  ActivityTableViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 5/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTAccountService.h"
#import "AdMobDelegateProtocol.h"

@class AdMobView;

@interface ActivityTableViewController : UITableViewController 
<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate,AdMobDelegate>{
    JTAccountService *accountService;
    
    NSArray *list;
    NSArray *labels;
    
    NSArray *sectionTitles;
    NSInteger carryScore;
    NSInteger photoScore;
    NSInteger arrivalScore;
    
    AdMobView *adMobAd;
}
- (void)setupDefaultTableData;
- (void) signIn:(id)sender;
- (void) refreshData;
- (void ) signOut:(id)sender;
- (void)didSignOut:(NSDictionary*)dict;
- (void)didFail:(ASIHTTPRequest*)request;

- (void) didGetAccountInfo:(NSDictionary*)dict;
@end
