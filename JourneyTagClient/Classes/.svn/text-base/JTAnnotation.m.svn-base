//
//  Tag.m
//  MapKit1
//
//  Created by Ben Ford on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTAnnotation.h"


@implementation JTAnnotation

@synthesize coordinate=myCoordinate, title=myTitle, subTitle=mySubtitle,withinPickupRange=myWithinPickupRange,key=myKey, level=myLevel, type=myType;

- (id) init:(NSString*)key coordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title subTitle:(NSString*)subTitle level:(int)level withinPickupRange:(BOOL)withinPickupRange
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
    [super dealloc];
}
@end
