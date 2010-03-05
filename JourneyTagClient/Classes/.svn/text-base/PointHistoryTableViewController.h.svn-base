//
//  PointHistoryTableViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTScoreService.h"

typedef enum  {
    JTScoreTypeCarry,
    JTScoreTypePhoto
} JTScoreType;

@interface PointHistoryTableViewController : UITableViewController {
    JTScoreService *scoreService;
    JTScoreType myScoreType;
    NSMutableArray *values;
    BOOL isLoading;
    BOOL usingDefaults;
}
- (id)initWithScore:(JTScoreType)scoreType;
- (void)setTitleForScoreType:(JTScoreType)scoreType;
- (void)fetchScoresForScoreType:(JTScoreType)scoreType;
@end
