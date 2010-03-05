//
//  JTMapViewDelegate.h
//  JourneyTag
//
//  Created by Ben Ford on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JTMapViewDelegate : NSObject
<MKMapViewDelegate>
{

}

- (MKPinAnnotationColor) detectPinColor:(CLLocationCoordinate2D)coord;
@end
