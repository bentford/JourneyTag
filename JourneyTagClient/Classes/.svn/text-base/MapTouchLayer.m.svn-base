//
//  MapTouchLayer.m
//  JourneyTag
//
//  Created by Ben Ford on 6/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapTouchLayer.h"


@implementation MapTouchLayer

- (id) initWithMapView:(MKMapView*)mapView
{
    self = [super initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
    [self setBackgroundColor:[UIColor clearColor]];
    
    [mapView addSubview:self];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    UIColor *lineColor = [UIColor blueColor];
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGRect centerSquare = CGRectMake(140, 163, 20, 20);
    CGContextAddRect(context, centerSquare);
    CGContextStrokePath(context);
}

@end
