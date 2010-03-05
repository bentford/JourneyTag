//
//  GreatCircleTests.h
//  JourneyTag
//
//  Created by Ben Ford on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
#import "GreatCircleDistance.h"
#import <MapKit/MapKit.h>

@interface GreatCircleTests : SenTestCase {
    CLLocationCoordinate2D one;
    CLLocationCoordinate2D two;
    CLLocationCoordinate2D three;
    CLLocationCoordinate2D four;
    
    CLLocationCoordinate2D bigOne;
    CLLocationCoordinate2D bigTwo;
}

- (void)setUp;
- (void)testMilesToMeters;
- (void)testDistanceInMeters;
- (void)testPaddingCalculation;
- (BOOL)floatsEqual:(float)first second:(float) second;
@end
