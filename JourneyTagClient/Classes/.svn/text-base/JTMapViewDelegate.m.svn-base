//
//  JTMapViewDelegate.m
//  JourneyTag
//
//  Created by Ben Ford on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTMapViewDelegate.h"
#import "JTAnnotation.h"
#import "DepotAnnotationView.h"

@implementation JTMapViewDelegate

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    if( [annotation isKindOfClass:[MKUserLocation class]] )
    {
        MKPinAnnotationView *userLoc = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"userLoc"] autorelease];
        
        userLoc.animatesDrop = NO;
        userLoc.canShowCallout = NO;
        userLoc.pinColor = MKPinAnnotationColorPurple;
        return userLoc;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:annotation action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    
    JTAnnotation *tag = (JTAnnotation*)annotation;
    if( tag.type == JTAnnotationTypeDepot )
    {
        DepotAnnotationView *depot = [[[DepotAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"depot"] autorelease];
        depot.canShowCallout = YES;
        depot.rightCalloutAccessoryView = button;
        return depot;
    } else {
        MKPinAnnotationView *pin = (MKPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        if( pin == nil)
        {
            pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];

            pin.animatesDrop = YES;
            pin.canShowCallout = YES;
            pin.rightCalloutAccessoryView = button;
        }
        pin.pinColor = [self detectPinColor:annotation.coordinate];
        return pin;
    }
}

- (MKPinAnnotationColor) detectPinColor:(CLLocationCoordinate2D)coord
{
    if( 
       (coord.latitude > 41.978928 && coord.latitude < 44.845594) && 
       (coord.longitude > -124.345375 && coord.longitude < -118.745375 )
       )
    {
        return MKPinAnnotationColorGreen;
    }
    return MKPinAnnotationColorRed;
}
@end
