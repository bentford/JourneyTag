//
//  TagDetailsTableViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTService.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface TagDetailsTableViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate>{
    NSString *tagKey;
    
    NSArray *list;
    NSArray *labels;
    
    NSMutableArray *infoSectionValues;
    NSArray *infoSectionLabels;
    
    NSArray *travelSectionValues;
    NSArray *travelSectionLabels;
    
    NSMutableArray *locSectionValues;
    NSArray *locSectionLabels;
    
    NSArray *dateSectionValues;
    NSArray *dateSectionLabels;
    
    JTTagService *tagService;
    
    CLLocationCoordinate2D currentLocation;
    CLLocationCoordinate2D destinationCoordinate; //cached for use after server request
    CLLocationCoordinate2D tagLocation; //cached also
    
    BOOL isNewTag;
    BOOL hasArrivedAtFinalDestination;
    BOOL hasReachedDestination;
    
    BOOL withinPickupRange;
    BOOL hasLocation;
    
    BOOL isUpdatingTable;
    
    BOOL youOwn;
    
    id pickupDelegate;
    SEL didPickupTagSelector;
    BOOL isDropped;
    
    CLLocationManager *locManager;
    
    BOOL shouldUpdateLocationValues;
    
    NSMutableArray *sectionTitles;
    
    int tagLevel;
    
    MKReverseGeocoder *geoCoder;
    
    int currentAccuracy;
    
    UITableView *myTableView;
    
    BOOL didLoadTag;
}
@property (nonatomic, retain) NSString *tagKey;
@property (nonatomic) BOOL withinPickupRange;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic) BOOL hasLocation;

@property (nonatomic,retain) UITableView *tableView;

@property (nonatomic, retain) id pickupDelegate;
@property (nonatomic ) SEL didPickupTagSelector;

- (void) pickupTag;
- (void) refreshData;
- (void) didLoadTag:(NSDictionary*)dict;
- (void) didFail:(id)sender;
- (void) loadLabels;

- (UITableViewCellAccessoryType) accessoryTypeForRowWithIndexPath:(NSIndexPath*)indexPath;
- (void)updateLocationValues;
- (void)reverseLookupTagLocation;

- (void)viewDidAppear:(BOOL)animated;
@end
