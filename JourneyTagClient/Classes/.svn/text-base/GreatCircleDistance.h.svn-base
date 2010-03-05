//
//  GreatCircleDistance.h
//  JourneyTag
//
//  Created by Ben Ford on 6/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#include <math.h>

#define kEarthRadiusInMeters 6378100.0 //based off google calculator 
#define kEarthRadiusInMiles 3962.71353

@interface GreatCircleDistance : NSObject {

}

+ (float)distance:(CLLocationCoordinate2D)first second:(CLLocationCoordinate2D)second;
+ (int)distanceInMeters:(CLLocationCoordinate2D)first second:(CLLocationCoordinate2D)second;

+ (float)calculatePaddingMaxCoord:(CLLocationCoordinate2D)maxCoord minCoord:(CLLocationCoordinate2D)minCoord vertical:(BOOL)vertical;

+ (float)toRadians:(float)degrees;
+ (float)toDegrees:(float)radians;

+ (NSString*) getBearingNameFromDegrees:(double)degrees;
+ (int) getBearingFromCoordinate:(CLLocationCoordinate2D)fromCoordinate toCoordinate:(CLLocationCoordinate2D)toCoordinate;

+ (CLLocationCoordinate2D) inverseFromCoordinate:(CLLocationCoordinate2D)coordinate miles:(NSInteger)miles degrees:(NSInteger)degrees;
+ (CLLocationCoordinate2D) inverseFromCoordinate:(CLLocationCoordinate2D)coordinate meters:(NSInteger)meters degrees:(NSInteger)degrees;
+ (int)milesToMeters:(float)miles;
+ (float)metersToMiles:(int)meters;
+ (float)ngt1:(float)x;
+ (float)hav:(float)x;
+ (float)ahav:(float)x;
+ (float)sec:(float)x;
+ (float)csc:(float)x;
@end
