//
//  Tag.m
//  MapKit1
//
//  Created by Ben Ford on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTAnnotation.h"


@implementation JTAnnotation

@synthesize coordinate=myCoordinate, title=myTitle, subTitle=mySubtitle,withinPickupRange=myWithinPickupRange,key=myKey, level=myLevel, type=myType, progressMeterText, distanceTraveled, totalDistance;
@synthesize destinationCoordinate;

- (id)init:(NSString*)key coordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title subTitle:(NSString*)subTitle level:(int)level withinPickupRange:(BOOL)withinPickupRange progressMeterText:(NSString *)theProgressMeterText distanceTraveled:(CGFloat)theDistanceTraveled totalDistance:(CGFloat)theTotalDistance destinationCoordinate:(CLLocationCoordinate2D)theDestinationCoordinate
{
    if( self = [super init] )
    {
        myKey = [key retain];
        myCoordinate = coordinate;
        myTitle = [title retain];
        mySubtitle = [subTitle retain];
        myType = JTAnnotationTypeTag;
        myLevel = level;
        myWithinPickupRange = withinPickupRange;
        progressMeterText = [theProgressMeterText retain];
        distanceTraveled = theDistanceTraveled;
        totalDistance = theTotalDistance;
        destinationCoordinate = theDestinationCoordinate;
    }
    return self;
}

- (id)init:(NSString*)key coordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title subTitle:(NSString*)subTitle
{
    if( self = [super init] )
    {
        myKey = [key retain];
        myCoordinate = coordinate;
        myTitle = [title retain];
        mySubtitle = [subTitle retain];
        myType = JTAnnotationTypeTag;
        myLevel = 0;
        myWithinPickupRange = NO;
        progressMeterText = @"";
        distanceTraveled = 0;
        totalDistance = 0;

        CLLocationCoordinate2D defaultCoordinate = {0.0, 0.0};
        destinationCoordinate = defaultCoordinate;
    }
    return self;
}

#pragma mark <MKAnnotation>
- (NSString*)title
{
    return myTitle;
}

- (NSString*)subtitle
{
    return mySubtitle;
}

#pragma mark Disclosure Button
- (void) buttonClick:(id)sender
{
    NSNumber *typeNumber = [[NSNumber alloc] initWithInt:myType];
    NSNumber *pickupRangeNumber = [[NSNumber alloc] initWithBool:myWithinPickupRange];

    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:myKey,@"key",typeNumber,@"type",pickupRangeNumber,@"withinPickupRange",nil];
    [typeNumber release];
    [pickupRangeNumber release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MarkWasTouched" object:self userInfo:info];
    [info release];
}


#pragma mark other
- (void)dealloc
{
    [myKey release];
    [myTitle release];
    [mySubtitle release];
    [progressMeterText release];
    
    [super dealloc];
}
@end
