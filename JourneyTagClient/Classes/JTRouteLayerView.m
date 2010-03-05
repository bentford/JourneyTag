//
//  JTRouteLayerView.m
//  JourneyTag
//
//  Created by Ben Ford on 6/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTRouteLayerView.h"
#import "GreatCircleDistance.h"

@implementation JTRouteLayerView
@synthesize drawDashed, region;

- (id)initWithLatList:(NSArray*)latList lonList:(NSArray*)lonList mapView:(MKMapView*)mapView lineColor:(UIColor*)color centerView:(BOOL)centerView
{
    self = [super initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
    [self setBackgroundColor:[UIColor clearColor]];

    myMapView = [mapView retain];
    myLatList = [latList retain];
    myLonList = [lonList retain];

    lineColor = [color retain];
    
    if( centerView )
    {
        region = [self calculateRegion];
        [myMapView setRegion:region animated:YES];
    }
    [self setUserInteractionEnabled:NO];
    [myMapView addSubview:self];

    return self;
}

- (MKCoordinateRegion)calculateRegion
{
    MKCoordinateRegion localRegion;
    
    // determine the extents of the trip points that were passed in, and zoom in to that area. 
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for(int index = 0; index < [myLonList count]; index++)
    {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[myLatList objectAtIndex:index] doubleValue];
        coordinate.longitude = [[myLonList objectAtIndex:index] doubleValue];
        
        if(coordinate.latitude > maxLat)
            maxLat = coordinate.latitude;
        if(coordinate.latitude < minLat)
            minLat = coordinate.latitude;
        if(coordinate.longitude > maxLon)
            maxLon = coordinate.longitude;
        if(coordinate.longitude < minLon)
            minLon = coordinate.longitude;
    }
    
    CLLocationCoordinate2D max = [self makeCLLocationCoordinate2DWithLat:maxLat lon:maxLon];
    CLLocationCoordinate2D min = [self makeCLLocationCoordinate2DWithLat:minLat lon:minLon];
    
    float latPadding = [GreatCircleDistance calculatePaddingMaxCoord:max minCoord:min vertical:YES];
    float lonPadding = [GreatCircleDistance calculatePaddingMaxCoord:max minCoord:min vertical:NO];
    
    localRegion.center.latitude     = (maxLat + minLat) / 2;
    localRegion.center.longitude    = (maxLon + minLon) / 2;
    localRegion.span.latitudeDelta  = maxLat - minLat + latPadding;
    localRegion.span.longitudeDelta = maxLon - minLon + lonPadding;   
    
    return localRegion;
}

- (CLLocationCoordinate2D)makeCLLocationCoordinate2DWithLat:(float)lat lon:(float)lon
{
    CLLocationCoordinate2D coord;
    coord.latitude = lat;
    coord.longitude = lon;
    
    return coord;
}

- (void)drawRect:(CGRect)rect
{
    // only draw our lines if we're not int he middie of a transition and we 
    if(!self.hidden && myLatList != nil && [myLatList count] > 0)
    {
        CGContextRef context = UIGraphicsGetCurrentContext(); 
        //UIColor *lineColor = [[UIColor blueColor] retain];

        CGFloat dash[] = {5.0, 5.0};
        
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
        
        if( drawDashed )
            CGContextSetLineDash(context, 0.0, dash, 2);
        // Draw them with a 2.0 stroke width so they are a bit more visible.
        CGContextSetLineWidth(context, 2.0);

        for(int index = 0; index < [myLatList count]; index++)
        {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [[myLatList objectAtIndex:index] doubleValue];
            coordinate.longitude = [[myLonList objectAtIndex:index] doubleValue];
    
            CGPoint point = [myMapView convertCoordinate:coordinate toPointToView:self];
    
            if(index == 0)
            {
                CGContextMoveToPoint(context, point.x, point.y);
            }
            else
            {
                CGContextAddLineToPoint(context, point.x, point.y);
            }
        }

        CGContextStrokePath(context);
    }
}

- (void)removeFromMapview
{
    [self removeFromSuperview];
}

-(void) dealloc
{
    [myMapView release];
    [myLatList release];
    [myLonList release];
    [lineColor release];
    
    [super dealloc];
}
@end
