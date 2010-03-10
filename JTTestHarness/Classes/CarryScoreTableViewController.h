//
//  TravelScoreTableViewController.h
//  JTTestHarness1
//
//  Created by Ben Ford on 8/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestBaseTableViewController.h"

@interface CarryScoreTableViewController : TestBaseTableViewController {
    NSString *accountKey;
    NSString *tagKey;
    NSData *imageData;
    
    NSArray *latList;
    NSArray *lonList;
    
    NSDictionary *firstSet;
    NSDictionary *secondSet;
    
    NSString *accountName1;
    NSString *accountName2;
    NSString *accountName3;
}

- (void)createAllAccounts;
- (void)compareAccountInfoChanges;
@end
