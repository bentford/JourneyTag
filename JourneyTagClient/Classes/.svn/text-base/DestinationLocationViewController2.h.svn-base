//
//  DestinationLocationViewController21.h
//  JourneyTag
//
//  Created by Ben Ford on 7/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "JTRouteLayerView.h"
#import "JTMarkService.h"
#import "JTDrawPickupRange.h"

@interface DestinationLocationViewController2 : UIViewController 
<MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKMapView *myMapView;
    
    CLLocationCoordinate2D destinationLocation;
    CLLocationCoordinate2D tagLocation;
    CLLocationCoordinate2D currentLocation;
    
    JTRouteLayerView *existingRoute;
    BOOL isNewTag;
    
    CLLocationManager *locManager;
    BOOL hasLocation;
    
    JTMarkService *markService;
    NSString *tagKey;
    
    JTRouteLayerView *destinationRoute;
    
    BOOL hasReachedDestination;
    BOOL isDropped;
    BOOL withinPickupRange;
    
    BOOL firstUpdate;
    int tagLevel;
    
    JTDrawPickupRange *destinationRange;
    BOOL shouldDrawRangeCircle;
    
    int currentAccuracy;
}

@property (nonatomic,retain) IBOutlet MKMapView *myMapView;

@property (nonatomic) CLLocationCoordinate2D destinationLocation;
@property (nonatomic) CLLocationCoordinate2D tagLocation;
@property (nonatomic) BOOL isNewTag;
@property (nonatomic,retain) NSString *tagKey;
@property (nonatomic) BOOL hasReachedDestination;
@property (nonatomic) BOOL isDropped;
@property (nonatomic) BOOL withinPickupRange;
@property (nonatomic) int tagLevel;
@property (nonatomic) int currentAccuracy;

- (void)showTagLocation;
- (void)didFail:(ASIHTTPRequest*)request;
- (void)loadDestinationRoute;

- (void)updateDestinationRoute;
- (BOOL)calculateIfShouldDrawRangeCircle:(NSArray*)latList lonList:(NSArray*)lonList;
@end
