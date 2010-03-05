//
//  JTAnnotation2.m
//  JourneyTag
//
//  Created by Ben Ford on 7/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTAnnotation2.h"


@implementation JTAnnotation2
@synthesize coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString*)title subtitle:(NSString*)subtitle
{

    self = [super init];
    
    coordinate = coord;
    myTitle = [title retain];
    mySubTitle = [subtitle retain];
    
    return self;
}
- (NSString*)title
{
    return myTitle;
}

-(NSString*)subtitle
{
    return mySubTitle;
}
- (void)setTitle:(NSString*)title
{
    [myTitle release];
    myTitle = [title retain];
}

- (void)dealloc
{
    [myTitle release];
    [mySubTitle release];
    [super dealloc];
}
@end
