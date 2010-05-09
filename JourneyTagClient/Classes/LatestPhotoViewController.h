//
//  LatestPhotoViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JTGameService, JTPhotoService;
@interface LatestPhotoViewController : UIViewController {
    IBOutlet UIScrollView *myScrollView;

    JTGameService *gameService;
    NSArray *photos;
    
    NSMutableArray *controllerList;
    
    int currentIndex;
}
- (id)init;
@end
