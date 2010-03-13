//
//  DropTableViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagHistoryViewController.h"
#import "JTService.h"

typedef enum {
    DropSubtitleModeMovedDistance,
    DropSubtitleModeGainLossDistance,
    DropSubtitleModeDestinationDistance
} DropSubtitleMode;

@class GpsInfoView;
@interface DropTableViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate>{
    NSMutableArray *list;
    NSMutableArray *keyList;
    NSMutableArray *depotList;
    NSMutableArray *depotKeyList;
    
    NSInteger viewMode;
    
    NSInteger selectedItemIndex;
    NSString *selectedKey;  //special case when early-purging visible tag list on drop
    
    CLLocationManager *locManager;
    CLLocation *currentLocation;
    BOOL hasLocation;
    
    JTDepotService *depotService;
    JTInventoryService *inventoryService;
    JTTagService *tagService;
    
    BOOL dropAndPickup;
    
    NSOperationQueue *queue;
    
    NSMutableArray *subtitleList;
    NSMutableArray *coordinateList;
    NSMutableArray *markCountList;
    NSMutableArray *destinationCoordinateList;
    NSMutableArray *subtitleColorList;
    NSMutableArray *payoutList;
    NSMutableArray *currentAccuracyList;
    NSMutableArray *showImageList;
    
    BOOL skipAutoRefresh;
    
    DropSubtitleMode subtitleMode;
    
    NSMutableDictionary *dropSettings;
    
    UIImage *destinationImage;
    
    BOOL hasTags;
    
    GpsInfoView *gpsInfoView;
    
    UITableView *theTableView;
}
- (void) takePicture;

- (UISegmentedControl*) createSegment;

- (void) didGetInventories:(NSDictionary*)dict;

- (void) didFail:(id)sender;
- (void) didDropTag:(NSDictionary*)dict;

- (void) refreshData:(id)sender;
- (void) refreshTags:(id)sender;
- (void) refreshDepots:(id)sender;


- (void) dropTagAtDepot:(NSDictionary*)data;

- (void) startLocationManager;

- (UITableViewCellAccessoryType) accessoryTypeForRowWithIndexPath:(NSIndexPath*)indexPath;
- (void) uploadImage:(NSData*)imageData;


- (int)incrementMode:(DropSubtitleMode)detailMode;
- (void)updateSubtitleMode;

- (void)updateStatusIcon;
- (void)updateMovedDistance;
- (void)updateDestinationDistance;
- (void)updateGainLossDistance;

- (UIBarButtonItem*)makeHelpButton;
- (UIBarButtonItem*)makeToggleButton;
@end
