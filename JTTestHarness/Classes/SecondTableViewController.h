//
//  SecondTableViewController.h
//  JTTestHarness1
//
//  Created by Ben Ford on 8/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestBaseTableViewController.h"

@interface SecondTableViewController : TestBaseTableViewController {
    NSString *accountKey;
    NSString *tagKey;
    NSData *imageData;
    
    NSArray *latList;
    NSArray *lonList;
    
    NSDictionary *firstSet;
    NSDictionary *secondSet;
}

- (void)compareAccountInfoChanges;
@end
