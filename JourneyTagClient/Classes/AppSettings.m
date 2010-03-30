//
//  AppSettings.m
//  JourneyTag
//
//  Created by Ben Ford on 8/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppSettings.h"
#import "GreatCircleDistance.h"

@implementation AppSettings
+ (CLLocationDistance)distanceFilter
{
    return 10; //meters
}

+ (CLLocationAccuracy)desiredAccuracy
{
    return kCLLocationAccuracyNearestTenMeters;
}

+ (int)pickupRangeInMeters
{
    return [GreatCircleDistance milesToMeters:5.0];
}

+ (int)desiredGpsAccuracyInMeters
{
    return 300;
}

+ (UIColor*)subtitleColorStandard
{
    return [UIColor grayColor];
}

+ (UIColor*)subtitleColorPositive
{
    return [UIColor colorWithRed:(0.0/255.0) green:(134.0/255.0) blue:(43.0/255.0) alpha:1.0];
}

+ (UIColor*)subtitleColorNegative
{
    return [UIColor redColor];
}

+ (float)imageQuality
{
    return 0.4;
}

+ (int)imageWidth
{
    return 320;
}

+ (int)imageHeight
{
    return 480;
}

+ (float)refreshOnScrollDistanceInMiles
{
    return 10.0f;
}

+ (NSString*)adWhirlApplicationKey
{
    return @"bc288147f309102c96dc5b26aef5c1e9";
}
@end
