//
//  AlternateViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TagMapLoader.h"
#import "JTRouteLayerView.h"

@interface AlternateViewController : UIViewController 
<MKMapViewDelegate>
{
    IBOutlet MKMapView *myMapView;
    IBOutlet UIBarButtonItem *tagCounter;
    
    CLLocationCoordinate2D currentLocation;
    int currentIndex;

    int tagIndex;
    
    NSMutableArray *myLatList;
    NSMutableArray *myLonList;
    
    JTRouteLayerView *route;
}
@property (nonatomic) int currentIndex;

- (id)initWithIndex:(int)index latList:(NSArray*)latList lonList:(NSArray*)lonList;

- (IBAction) moveBack;
- (IBAction) moveForward;
- (void) populateLocations;

- (void) moveToCurrentLocation;
- (void) setImageCounter;
@end
