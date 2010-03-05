//
//  GreatCircleTests.m
//  JourneyTag
//
//  Created by Ben Ford on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "GreatCircleTests.h"

#define kFiftyMilesToMeters 80467

@implementation GreatCircleTests

- (void)setUp {
    one.latitude =  42.355901;
    one.longitude = -123.697748;
    two.latitude =  42.355901;
    two.longitude = -122.717808;
    three.latitude =   41.994871;
    three.longitude = -123.207778;
    four.latitude =  42.355901;
    four.longitude = -122.717808;
    
    bigOne.latitude = 42.443641;
    bigOne.longitude = -124.343724;
    bigTwo.latitude =  36.639667;
    bigTwo.longitude = -78.029245;
}

- (void)testMilesToMeters {
    int meters = [GreatCircleDistance milesToMeters:50.0];
    STAssertEquals(kFiftyMilesToMeters, meters, @"%d != %d milesToMeters",kFiftyMilesToMeters,meters);
}
- (void)testDistanceInMeters {
    int distance = [GreatCircleDistance distanceInMeters:one second:two];
    STAssertEquals( 80644, distance, @"off by %d small distanceInMeters",80644-distance );
    
    distance = [GreatCircleDistance distanceInMeters:bigOne second:bigTwo];
    STAssertEquals( 3978548, distance, @"off by %d big distanceInMeters",3978548-distance );
}

- (void)testDistanceInMiles {
    float distance = [GreatCircleDistance distance:one second:two];
    STAssertEquals( 50.083042f, distance, @"%f != %f distanceInMiles",50.083042, distance );    
}

- (void)testPaddingCalculation {
    float padding = [GreatCircleDistance calculatePaddingMaxCoord:one minCoord:two vertical:NO];
    STAssertTrue([self floatsEqual:0.245493f second:padding], @"padding is %f", padding);
}

- (BOOL)floatsEqual:(float)first second:(float) second {
    return fabs((first - second) / second) <= 0.00001;
}
                                  
@end