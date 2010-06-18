//
//  TagsViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 4/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "JTTagService.h"

@interface TagsViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>{
    NSMutableArray *list;
    NSMutableArray *keyList;
    
    NSMutableArray *completedList;
    NSMutableArray *completedKeyList;

    NSMutableArray *dateCreatedList;
    NSMutableArray *completedDateCreatedList;
    NSMutableArray *problemCodeList;
    
    NSArray *sectionTitles;
    
    BOOL hasLocation;
    CLLocationManager *locationManager;
    
    BOOL isUpdatingTable;
    
    JTTagService *tagService;
    
    NSMutableDictionary *tagViewLog;
    NSMutableArray *tagActivityList;
    
    NSMutableArray *notDroppedStatusList;
    
    NSMutableArray *finishedTagActivityList;
    
    UITableView *myTableView;
}
@property (nonatomic,retain) NSMutableArray *list;

- (void) didFail:(id)sender;
- (void) didLoadTags:(NSDictionary*)dict;

- (void) refreshTags:(id)sender;
-(void)newTag;

- (UIBarButtonItem*) createRefreshButton;
- (void) saveTagViewLog:(id)sender;
@end
