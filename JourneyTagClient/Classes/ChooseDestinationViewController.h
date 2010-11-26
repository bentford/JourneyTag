//
//  ChooseDestinationViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 6/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ChooseDestinationViewController : UIViewController <MKMapViewDelegate> {
    IBOutlet MKMapView *myMapView;

    CLLocationCoordinate2D defaultLocation;
    BOOL hasDefaultLocation;
}
@property (nonatomic) CLLocationCoordinate2D defaultLocation;
@property (nonatomic) BOOL hasDefaultLocation;

- (id)init;
@end
