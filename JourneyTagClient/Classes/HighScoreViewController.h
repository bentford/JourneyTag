//
//  HighScoreViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JTGameService;
@interface HighScoreViewController : UITableViewController {
	NSArray *accounts;
	JTGameService *gameService;
}

@end
