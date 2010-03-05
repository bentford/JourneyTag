//
//  ScoreBreakdownTableViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 7/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScoreBreakdownTableViewController : UITableViewController {
    NSInteger myCarryScore;
    NSInteger myPhotoScore;
    
    NSArray *cellLabels;
    NSArray *cellValues;
    NSArray *sectionTitles;
    NSInteger helpCellHeight;
}
- (id)initWithCarryScore:(NSInteger)carryScore photoScore:(NSInteger)photoScore;
@end
