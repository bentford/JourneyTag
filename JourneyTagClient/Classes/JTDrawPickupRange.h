//
//  JTDrawPickupRange.h
//  JourneyTag
//
//  Created by Ben Ford on 8/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JTDrawPickupRange : UIView {
    MKMapView *myMapView;
    CLLocationCoordinate2D myCoordinate;
    UIColor *myColor;
    int myMeters;
    
    BOOL useDefaultColor;
    BOOL useUserLocation;
}
- (id)initWithMapView:(MKMapView*)mapView sizeInMeters:(int)meters;
- (id)initWithMapView:(MKMapView*)mapView coordinate:(CLLocationCoordinate2D)coordinate sizeInMeters:(int)meters color:(UIColor*)color;

- (void)useCustomCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)useCurrentLocation;
- (CGPoint)centerOfRect:(CGRect)rect;
-(void)drawText:(CGContextRef)myContext atPoint:(CGPoint)point height:(float)height;


@end
