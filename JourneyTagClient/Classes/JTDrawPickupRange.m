//
//  JTDrawPickupRange.m
//  JourneyTag
//
//  Created by Ben Ford on 8/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTDrawPickupRange.h"
#import "GreatCircleDistance.h"

@implementation JTDrawPickupRange

- (id)initWithMapView:(MKMapView*)mapView sizeInMeters:(int)meters
{
    self = [super initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:NO];
    
    myMeters = meters;
    myMapView = mapView; //weak reference
    
    useDefaultColor = YES;
    useUserLocation = YES;
    
    [myMapView addSubview:self];
    return self;
}

- (id)initWithMapView:(MKMapView*)mapView coordinate:(CLLocationCoordinate2D)coordinate sizeInMeters:(int)meters color:(UIColor*)color
{
    self = [super initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];

    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:NO];
    
    myCoordinate = coordinate;
    myMeters = meters;
    myColor = [color retain];
    myMapView = mapView; //weak reference
    
    useDefaultColor = NO;
    useUserLocation = NO;
    
    [myMapView addSubview:self];
    return self;
}

- (void)useCustomCoordinate:(CLLocationCoordinate2D)coordinate
{
    myCoordinate = coordinate;
    useUserLocation = NO;
}

- (void)useCurrentLocation
{
    useUserLocation = YES;
}

- (void)drawRect:(CGRect)rect
{
    // only draw our lines if we're not int he middie of a transition and we 
    if( !self.hidden )
    {
        CGContextRef context = UIGraphicsGetCurrentContext(); 
        
        if( useDefaultColor )
            CGContextSetRGBStrokeColor(context, 0.25, 0.65, 0.16, 1.0 ); //backwords compatibility
        else
            CGContextSetStrokeColorWithColor(context, myColor.CGColor);
        
        CGFloat dash[] = {5.0, 5.0};        
        CGContextSetLineDash(context, 0.0, dash, 2);
        
        CGContextSetLineWidth(context, 3.0);
        
        if( useUserLocation )
            myCoordinate = [myMapView userLocation].location.coordinate;

        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myCoordinate, myMeters*2, myMeters*2);
        
        CGRect rect = [myMapView convertRegion:region toRectToView:self];
        
        CGContextAddEllipseInRect(context, rect);
        CGContextStrokePath(context);
        //float height = ((float)rect.size.height)/10.0;
        //[self drawText:context atPoint:[self centerOfRect:rect] height:height];
        /*
        CGPoint center = [self centerOfRect:rect];
        UILabel *message = [[UILabel alloc] init];
        message.text = @"5 Miles";
        message.frame = CGRectMake(center.x, center.y, 100, 50);
        message.backgroundColor = [UIColor whiteColor];
        message.transform = CGAffineTransformMakeRotation([GreatCircleDistance toRadians:-45]);
        [self addSubview:message];
        */
    }
}

- (CGPoint)centerOfRect:(CGRect)rect
{
    CGPoint center;
    center.x = rect.origin.x + rect.size.width / 2;
    center.y = rect.origin.y + rect.size.height / 2;

    return center;
}

-(void)drawText:(CGContextRef)myContext atPoint:(CGPoint)point height:(float)height
{    
    CGRect viewBounds = myMapView.bounds;
    point.y = viewBounds.size.height - point.y;
    point.x = point.x + 10;
    point.y = point.y + 10;
    CGContextTranslateCTM(myContext, 0, viewBounds.size.height);
    CGContextScaleCTM(myContext, 1, -1);
    
    CGAffineTransform myTextTransform; // 2
    CGContextSelectFont (myContext, // 3
                         "Helvetica-Bold",
                         height,
                         kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (myContext, 2); // 4
    CGContextSetTextDrawingMode (myContext, kCGTextFill); // 5
    
    myTextTransform =  CGAffineTransformMakeRotation([GreatCircleDistance toRadians:45]); // 8
    
    CGContextSetTextMatrix (myContext, myTextTransform); // 9
    CGContextShowTextAtPoint (myContext, point.x, point.y, "5 miles", 7); // 10
}

- (void)dealloc
{
    [myColor release];
    [super dealloc];
}
@end
