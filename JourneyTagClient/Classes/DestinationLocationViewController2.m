//
//  DestinationLocationViewController21.m
//  JourneyTag
//
//  Created by Ben Ford on 7/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DestinationLocationViewController2.h"
#import "JTAnnotation2.h"
#import "TagAnnotationView.h"
#import "AppSettings.h"
#import "GreatCircleDistance.h"

@implementation DestinationLocationViewController2
@synthesize myMapView, destinationLocation, tagLocation, isNewTag;
@synthesize tagKey, hasReachedDestination,isDropped, withinPickupRange, tagLevel;
@synthesize currentAccuracy;

- (id) init
{
    self = [super init];
    self.title = @"Tag Destination";    
    currentAccuracy = [GreatCircleDistance milesToMeters:10];
    
    return self;
}

- (void)viewDidLoad //if you change this, everything stops working.  I don't know why...
{
    [super viewDidLoad];

    myMapView.delegate = self;
    myMapView.showsUserLocation = YES;
    hasLocation = NO;
    
    if( !isNewTag )
        [self showTagLocation];
    
    firstUpdate = YES;
    
    [self loadDestinationRoute];
}

- (void)viewWillAppear:(BOOL)animated
{
    if( locManager )
    {
        [locManager startUpdatingLocation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [locManager stopUpdatingLocation];
}

- (void)showTagLocation
{
    JTAnnotation2 *annotation = [[JTAnnotation2 alloc] initWithCoordinate:tagLocation title:@"Tag Location" subtitle:nil];
    
    [myMapView addAnnotation:annotation];
    [annotation release];
}

- (void)didFail:(ASIHTTPRequest*)request
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't load from server" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [alertView show];
    [alertView release];   
}

- (void)loadDestinationRoute
{
    BOOL isPickedUp = !isDropped;  //less confusing?
    
    if( (isNewTag || isPickedUp) && !hasLocation)
    {
        locManager = [[CLLocationManager alloc] init];
        locManager.distanceFilter = [AppSettings distanceFilter];
        locManager.desiredAccuracy = [AppSettings desiredAccuracy];
        locManager.delegate = self;
        [locManager startUpdatingLocation];
        
        return;
    }
    
    UIColor *color = [UIColor greenColor];
    
    if( (isNewTag || isPickedUp) && hasLocation) //redundant, but clear
    {
        tagLocation = currentLocation;
        color = [UIColor blueColor];
    }
    
    NSArray *latList = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:tagLocation.latitude], [NSNumber numberWithFloat:destinationLocation.latitude],nil];
    NSArray *lonList = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:tagLocation.longitude],[NSNumber numberWithFloat:destinationLocation.longitude],nil];
    [destinationRoute release];
    destinationRoute = [[JTRouteLayerView alloc] initWithLatList:latList lonList:lonList mapView:myMapView lineColor:color centerView:YES];    
    
    [destinationRoute setNeedsDisplay];
    
    JTAnnotation2 *destinationAnnotation = [[JTAnnotation2 alloc] initWithCoordinate:destinationLocation title:@"Destination" subtitle:nil];
    [myMapView addAnnotation:destinationAnnotation];
    [destinationAnnotation release];
    
    CLLocationCoordinate2D lastCoordinate;
    lastCoordinate.latitude = [[latList objectAtIndex:[latList count] - 1] floatValue];
    lastCoordinate.longitude = [[lonList objectAtIndex:[lonList count] - 1] floatValue];
    
    shouldDrawRangeCircle = [self calculateIfShouldDrawRangeCircle:latList lonList:lonList];
    if( shouldDrawRangeCircle )
    {
        destinationRange = [[JTDrawPickupRange alloc] initWithMapView:myMapView coordinate:lastCoordinate sizeInMeters:currentAccuracy color:[UIColor blueColor]];
        [destinationRange setNeedsDisplay];
    }
    
    [latList release];
    [lonList release];
}

- (BOOL)calculateIfShouldDrawRangeCircle:(NSArray*)latList lonList:(NSArray*)lonList
{
    CLLocationCoordinate2D first, second;
    first.latitude = [[latList objectAtIndex:0] floatValue];
    first.longitude = [[lonList objectAtIndex:0] floatValue];

    second.latitude = [[latList objectAtIndex:1] floatValue];
    second.longitude = [[lonList objectAtIndex:1] floatValue];
    
    float miles = [GreatCircleDistance distance:first second:second];
    return miles < 150;
}

- (void)updateDestinationRoute
{
    NSArray *latList = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:currentLocation.latitude], [NSNumber numberWithFloat:destinationLocation.latitude],nil];
    NSArray *lonList = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:currentLocation.longitude],[NSNumber numberWithFloat:destinationLocation.longitude],nil];

    [destinationRoute removeFromMapview];
    [destinationRoute release];

    destinationRoute = [[JTRouteLayerView alloc] initWithLatList:latList lonList:lonList mapView:myMapView lineColor:[UIColor blueColor] centerView:YES];    
    
    CLLocationCoordinate2D lastCoordinate;
    lastCoordinate.latitude = [[latList objectAtIndex:[latList count] - 1] floatValue];
    lastCoordinate.longitude = [[lonList objectAtIndex:[lonList count] - 1] floatValue];
    
    shouldDrawRangeCircle = [self calculateIfShouldDrawRangeCircle:latList lonList:lonList];
    if( shouldDrawRangeCircle )
    {
        destinationRange = [[JTDrawPickupRange alloc] initWithMapView:myMapView coordinate:lastCoordinate sizeInMeters:currentAccuracy color:[UIColor blueColor]];
        [destinationRange setNeedsDisplay];
    }
    
    
    [latList release];
    [lonList release];
    
    [destinationRoute setNeedsDisplay];
    
    if( firstUpdate )
    {
        JTAnnotation2 *destinationAnnotation = [[JTAnnotation2 alloc] initWithCoordinate:destinationLocation title:@"Destination" subtitle:nil];
        [myMapView addAnnotation:destinationAnnotation];
        [destinationAnnotation release];
    }
    
    firstUpdate = NO;
}

#pragma mark MKMapViewDelegate
    
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    CLLocationCoordinate2D coordinate;
    coordinate = annotation.coordinate;
    if( coordinate.latitude == destinationLocation.latitude && coordinate.longitude == destinationLocation.longitude )
    {
        MKAnnotationView *finishView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"finish"] autorelease];
        finishView.canShowCallout = YES;
        ((JTAnnotation2*)annotation).title = @"Destination";
        finishView.image = [UIImage imageNamed:@"FinishIcon2.png"];
        
        return finishView;
        
    } else if(  coordinate.latitude == tagLocation.latitude && coordinate.longitude == tagLocation.longitude )
    {
        if( isNewTag )
        {
            MKPinAnnotationView *pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];
            pin.pinColor =  MKPinAnnotationColorGreen;
                
            return pin;
            
        } else {
            MKAnnotationView *tagView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"tag"] autorelease];    

            if( isDropped )
            {         
                [TagAnnotationView addEmblem:tagView withinPickupRange:withinPickupRange level:tagLevel];
            } else {
                ((JTAnnotation2*)annotation).title = @"Picked up at";
                tagView.image = [UIImage imageNamed:@"MapTagIconOutline4.png"];    
            }
            tagView.canShowCallout = YES;
            return tagView;
        }
        
    } else {
        return [mapView viewForAnnotation:annotation];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if( shouldDrawRangeCircle)
        destinationRange.hidden = YES;
    destinationRoute.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if( shouldDrawRangeCircle) 
    {
        destinationRange.hidden = NO;
        [destinationRange setNeedsDisplay];
    }
    
    destinationRoute.hidden = NO;
    [destinationRoute setNeedsDisplay];
    
}

#pragma mark LocationManager
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    hasLocation = YES;
    currentLocation = newLocation.coordinate;

    [self updateDestinationRoute];
}

#pragma mark Other
- (void)dealloc {
    [myMapView release];
    [existingRoute release];
    
    [locManager stopUpdatingLocation];
    [locManager release];
    
    myMapView.showsUserLocation = NO;
    [destinationRange release];
    
    [super dealloc];
}


@end