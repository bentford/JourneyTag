//
//  DistanceTextUtil.h
//  JourneyTag
//
//  Created by Ben Ford on 9/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GreatCircleDistance.h"

@interface DistanceTextUtil : NSObject {

}
+ (NSString*)createDistanceTextFromCurrentLocation:(CLLocationCoordinate2D)current destinationCoordinate:(CLLocationCoordinate2D)destination;
+ (NSString *)createProgressMeterTextFrom:(CGFloat)distanceTraveled currentCoordinate:(CLLocationCoordinate2D)current destinationCoordinate:(CLLocationCoordinate2D)destination;
+ (NSString *)describeRegion:(MKCoordinateRegion)region;
@end
