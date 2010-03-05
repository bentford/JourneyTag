//
//  TraveledMapViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JTMarkService.h"
#import "JTRouteLayerView.h"
#import "JTTagService.h"
#import "JTDrawPickupRange.h"

@interface TraveledMapViewController : UIViewController 
<MKMapViewDelegate>
{
    IBOutlet MKMapView *myMapView;

    NSString *myTagKey;
    JTMarkService *markService;    
    JTTagService *tagService;
    JTRouteLayerView *route;
    
    CLLocationCoordinate2D destinationCoordinate;
    int currentAccuracy;
    
    JTDrawPickupRange *destinationRange;
}
- (id)initWithTagKey:(NSString*)tagKey;
- (void)loadData;
@end
