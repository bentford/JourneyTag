//
//  PhotoInfoTableViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 7/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoInfoTableViewController : UITableViewController {
    NSInteger currentIndex;
    NSString *date;
}
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic,retain) NSString *date;

- (id)init;

@end
