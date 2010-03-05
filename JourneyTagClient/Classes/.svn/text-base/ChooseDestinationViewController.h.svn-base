//
//  ChooseDestinationViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 6/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapTouchLayer.h"

@interface ChooseDestinationViewController : UIViewController
<MKMapViewDelegate>
{
    IBOutlet MKMapView *myMapView;
    MapTouchLayer *layer;
    CLLocationCoordinate2D defaultLocation;
    BOOL hasDefaultLocation;
}
@property (nonatomic) CLLocationCoordinate2D defaultLocation;
@property (nonatomic) BOOL hasDefaultLocation;

- (void) setDestination:(id)sender;
@end
