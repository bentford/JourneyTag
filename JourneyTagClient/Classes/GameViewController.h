//
//  GameViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HideAdHelper.h"
#import <iAd/iAd.h>

@interface GameViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, HideAdHelperDelegate, ADBannerViewDelegate> {
    NSArray *titles;
    
    UITableView *myTableView;
    ADBannerView *adView;
    HideAdHelper *hideAdHelper;
}

@end
