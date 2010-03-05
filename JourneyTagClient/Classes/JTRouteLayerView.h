//
//  JTRouteLayerView.h
//  JourneyTag
//
//  Created by Ben Ford on 6/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface JTRouteLayerView : UIView {
    MKMapView *myMapView;
    NSArray *myLatList;
    NSArray *myLonList;
    BOOL drawDashed;
    UIColor *lineColor;
    
    MKCoordinateRegion region;
}
@property BOOL drawDashed;
@property (readonly) MKCoordinateRegion region;

- (id)initWithLatList:(NSArray*)latList lonList:(NSArray*)lonList mapView:(MKMapView*)mapView lineColor:(UIColor*)color centerView:(BOOL)centerView;
- (void)removeFromMapview;
- (CLLocationCoordinate2D)makeCLLocationCoordinate2DWithLat:(float)lat lon:(float)lon;
- (MKCoordinateRegion)calculateRegion;
@end
