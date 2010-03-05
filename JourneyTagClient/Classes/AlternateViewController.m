//
//  AlternateViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AlternateViewController.h"
#import "TagMapLoader.h"
#import "GreatCircleDistance.h"

@implementation AlternateViewController
@synthesize currentIndex;

- (id)initWithIndex:(int)index latList:(NSArray*)latList lonList:(NSArray*)lonList
{
    self = [super init];
    
    myLatList = [latList retain];
    myLonList = [lonList retain];
    currentIndex = index;
    
    return self;
}

- (void) viewDidLoad
{ 
    myMapView.delegate = self;
    [self populateLocations];    
    route = [[JTRouteLayerView alloc] initWithLatList:myLatList lonList:myLonList mapView:myMapView lineColor:[UIColor blueColor] centerView:NO];

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    myMapView.delegate = nil;
    tagCounter.title = nil;
    [myMapView removeAnnotations:myMapView.annotations];
    
    [route release];
    route = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setImageCounter];
    [self moveToCurrentLocation];
    
    [super viewDidAppear:animated];
}

- (void)setImageCounter
{
    int count = [myLatList count];
    NSString *message = [[NSString alloc] initWithFormat:@"%d of %d", count - currentIndex, count];
    tagCounter.title = message;
    [message release];
}

- (IBAction) moveForward
{
    currentIndex++;
    if( currentIndex > [myLatList count]-1 )
    {
        currentIndex = [myLatList count]-1;
        return;
    }

    [self setImageCounter];
    [self moveToCurrentLocation];
}

- (IBAction) moveBack
{
    currentIndex--;
    if( currentIndex < 0 )
    {
        currentIndex = 0;
        return;
    }
    [self setImageCounter];    
    [self moveToCurrentLocation];
}

- (void) moveToCurrentLocation
{
    currentLocation.latitude = [[myLatList objectAtIndex:currentIndex] doubleValue]; 
    currentLocation.longitude = [[myLonList objectAtIndex:currentIndex] doubleValue];
    float meters = [GreatCircleDistance milesToMeters:2];
    route.hidden = YES;
    [myMapView setRegion:MKCoordinateRegionMakeWithDistance(currentLocation, meters, meters) animated:NO];
    route.hidden = NO;
    [route setNeedsDisplay];
}

- (void) populateLocations
{
    int count = [myLatList count];
    for( int i = 0; i < count; i++ ) 
    {
        [TagMapLoader loadTag:myMapView lat:[[myLatList objectAtIndex:i] doubleValue] lon:[[myLonList objectAtIndex:i] doubleValue]];
    }
}


#pragma mark MapDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    if( pin == nil )
    {
        pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];
        pin.canShowCallout = NO;
    }
    return pin;
    
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"route was hidden");
    route.hidden = YES;
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"route was shown");
	route.hidden = NO;
	[route setNeedsDisplay];
}

- (void)dealloc 
{
    [myLatList release];
    [myLonList release];
    [route release];
    
    [super dealloc];
}


@end
