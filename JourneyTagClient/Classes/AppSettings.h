//
//  AppSettings.h
//  JourneyTag
//
//  Created by Ben Ford on 8/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define kTestAdLoadFailureAnimation NO

@interface AppSettings : NSObject {

}

+ (CLLocationDistance)distanceFilter;
+ (CLLocationAccuracy)desiredAccuracy;
+ (int)pickupRangeInMeters;

+ (int)desiredGpsAccuracyInMeters;

+ (UIColor*)subtitleColorStandard;
+ (UIColor*)subtitleColorPositive;
+ (UIColor*)subtitleColorNegative;

+ (float)imageQuality;
+ (int)imageWidth;
+ (int)imageHeight;

+ (float)refreshOnScrollDistanceInMiles;

+ (NSString*)adWhirlApplicationKey;
@end
