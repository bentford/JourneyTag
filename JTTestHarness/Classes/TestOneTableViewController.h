//
//  TestOneTableViewController.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTService.h"
#import "JTServiceHttpRequest.h"

@interface TestOneTableViewController : UITableViewController
<UITableViewDelegate, UITableViewDataSource>{

    JTAccountService *accountService;
    JTDepotService *depotService;
    JTMarkService *markService;
    JTPhotoService *photoService;
    JTTagService *tagService;
    JTInventoryService *inventoryService;
    JTScoreService *scoreService;
    NSMutableArray *titles;
    
    NSString *accountKey;
    NSString *tagKey;
    NSString *photoKey;
    NSString *depotKey;
    
    BOOL shouldTestLogout;
}
@property (nonatomic, retain) NSString *accountKey;
@property (nonatomic, retain) NSString *tagKey;
@property (nonatomic, retain) NSString *photoKey;
- (void) runTestStructure;
- (void) run2:(NSDictionary*)dict;
- (void) run2_0:(NSDictionary*)dict;
- (void) run2_1:(NSDictionary*)dict;
- (void) run2_2:(NSDictionary*)dict;
- (void) run2_3:(NSDictionary*)dict;
- (void) run3:(NSDictionary*)dict;
- (void) run4:(NSDictionary*)dict;
- (void) run5:(NSDictionary*)dict;
- (void) run6:(NSDictionary*)dict;
- (void) run7:(NSDictionary*)dict;
- (void) run8:(NSDictionary*)dict;
- (void) run9:(NSDictionary*)dict;
- (void) run10:(NSDictionary*)dict;
- (void) run11:(NSDictionary*)dict;
- (void) run12:(NSDictionary*)dict;
- (void) run13:(NSDictionary*)dict;
- (void) run14:(NSDictionary*)dict;
- (void) run15:(NSDictionary*)dict;
- (void) run16:(NSDictionary*)dict;
- (void) run17:(NSDictionary*)dict;
- (void) run19:(NSDictionary*)dict;
- (void)run20:(NSDictionary*)dict;
- (void)run20_1:(NSDictionary*)dict;
- (void) run21:(NSDictionary*)dict;
- (void) run22:(NSDictionary*)dict;
- (void)run23:(NSDictionary*)dict;
- (void)run24:(NSDictionary*)dict;
- (void) run25:(NSDictionary*)dict;
- (void) didFail:(JTServiceHttpRequest*)request;
- (void) updateTable:(NSString*)message;
@end
