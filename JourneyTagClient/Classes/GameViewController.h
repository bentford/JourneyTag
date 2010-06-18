//
//  GameViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GameViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *titles;
    
    UITableView *myTableView;
}

@end
