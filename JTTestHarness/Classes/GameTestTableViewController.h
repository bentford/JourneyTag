//
//  GameTestTableViewController.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestBaseTableViewController.h"

@class JTGameService;
@interface GameTestTableViewController : TestBaseTableViewController {
    JTGameService *gameService;
}

@end
