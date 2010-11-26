//
//  PickupViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 4/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DepotIndexTableViewController.h"
#import <MapKit/MapKit.h>
#import "JTService.h"
#import "JTMapViewDelegate.h"
#import "TagMapLoader.h"
#import "JTDrawPickupRange.h"
#import "ChooseDestinationMap.h"

@interface PickupViewController : UIViewController 
<CLLocationManagerDelegate, MKMapViewDelegate, UIActionSheetDelegate, MKReverseGeocoderDelegate>
{
   MKMapView *myMapView;

    
    BOOL hasLocation;
    BOOL hasPreviouslySelectedDepot;
    BOOL followCurrentLocation;
    
    NSTimer *locationRefreshTimer;
    NSTimer *mapRefreshTimer;
    
    NSDictionary* lastSelectedDepot;
    
    CLLocationCoordinate2D currentLocation;
    CLLocationCoordinate2D currentViewCoordinate;
    
    CLLocationManager *locManager;
    
    JTTagService *tagService;
    JTDepotService *depotService;
    JTPhotoService *photoService;
    
    JTDrawPickupRange *pickupRangeView;
    
    int messageState;
    
    UIView *messageView;
    BOOL messageVisible;
    
    NSString *selectedTagKey;
    // tracks annotationViews so I can remove observers when deleting annotations from map
    NSMutableDictionary *annotationViews;
    
    MKReverseGeocoder *geocoder;
    NSTimer *geocodeTimeout;
    
    BOOL shouldAnimateCallout;
    
    BOOL isRunningHideAnimation;
    BOOL isRunningShowAnimation;
    
#pragma mark PickupInfoView
    IBOutlet UIView *pickupInfoView;
    IBOutlet UILabel *distanceTraveledLabel;
    IBOutlet UILabel *destinationNameLabel;
    IBOutlet UIView *distanceMeterContainer;
	IBOutlet UIButton *pickupButton;
#pragma mark -
	
#pragma mark DistanceMeterView
	IBOutlet UIView *distanceMeterView;
	IBOutlet UIImageView *progressGreen;
	IBOutlet UIImageView *progressOrange;
#pragma mark -
    
#pragma mark TagCalloutView
    IBOutlet UIView *customTagCallout;
    IBOutlet UILabel *calloutTitle;
    IBOutlet UILabel *calloutDestinationDirection;
    IBOutlet UIImageView *calloutImage;
    IBOutlet UIActivityIndicatorView *calloutActivity;
#pragma mark -
    
}
@property (nonatomic, retain) IBOutlet MKMapView *myMapView;

- (UISegmentedControl*) createSegment;
- (void) changedMapType:(id)sender;

- (void) showDepotIndex;
- (void)didChooseDepot:(NSDictionary*)depot;

- (void) markWasTouched:(NSNotification*)notification;

- (void) loadTagsForCurrentLocation:(id)sender;
- (void) locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation;

- (void) gotoCurrentLocation;

- (void) startLocationManager;

- (void) didLoadTags:(NSDictionary*)dict;
- (void) addGotoButton;
- (void) gotoButtonPressed:(id)sender;

- (void) startRefreshTimer;
- (void) stopShowingRefresh:(id)sender;

- (void) createScrollCheckTimer;
- (void)setMapType:(int)typeNumber;

- (void)loadDepotOntoMap:(NSDictionary*)depot;

#pragma mark PickupInfoView Actions
- (IBAction)pickupTagAction:(id)sender;
- (IBAction)moreInfoAction:(id)sender;
#pragma mark -

- (void)geocodeTimedOut:(NSTimer *)timer;
@end
