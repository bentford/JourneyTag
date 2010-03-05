//
//  DistanceTextUtil.m
//  JourneyTag
//
//  Created by Ben Ford on 9/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DistanceTextUtil.h"


@implementation DistanceTextUtil

+ (NSString*)createDistanceTextFromCurrentLocation:(CLLocationCoordinate2D)current destinationCoordinate:(CLLocationCoordinate2D)destination
{
    int bearingDegrees = [GreatCircleDistance getBearingFromCoordinate:current toCoordinate:destination];
    NSString *bearingName = [GreatCircleDistance getBearingNameFromDegrees:bearingDegrees];
    int meters = [GreatCircleDistance distanceInMeters:current second:destination];
    float miles = [GreatCircleDistance metersToMiles:meters];
    
    NSString *distanceText;
    if( miles < 0.25 )
        distanceText = [[NSString alloc] initWithFormat:@"%d yards to the %@", meters, bearingName];        
    else
        distanceText = [[NSString alloc] initWithFormat:@"%1.2f miles to the %@", miles, bearingName];
    
    [distanceText autorelease];
    return distanceText;
}
@end
