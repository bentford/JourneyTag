//
//  TestBaseTableViewController.h
//  JTTestHarness1
//
//  Created by Ben Ford on 8/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTService.h"
#import "JTServiceHttpRequest.h"

@interface TestBaseTableViewController : UITableViewController {
    JTAccountService *accountService;
    JTDepotService *depotService;
    JTMarkService *markService;
    JTPhotoService *photoService;
    JTTagService *tagService;
    JTInventoryService *inventoryService;
    JTScoreService *scoreService;
    NSMutableArray *titles;
}

- (void) runTestStructure;
- (void) updateTable:(NSString*)message;

@end
