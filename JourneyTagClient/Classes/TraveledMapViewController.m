//
//  TraveledMapViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TraveledMapViewController.h"
#import "JTAnnotation2.h"

@implementation TraveledMapViewController

- (id)initWithTagKey:(NSString*)tagKey
{
    self = [super init];
    
    myTagKey = tagKey;
    currentAccuracy = 0;
    destinationCoordinate.latitude = 0;
    destinationCoordinate.longitude = 0;
    
    return self;
}

- (void)viewDidLoad 
{
    self.title = @"Travel Path";
    myMapView.delegate = self;
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.title = nil;
    myMapView.delegate = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadData];
    [super viewDidAppear:YES];
}

- (void)loadData
{
    if( !markService)
        markService = [[JTMarkService alloc] init];
    if( !tagService )
        tagService = [[JTTagService alloc] init];
    
    [tagService get:myTagKey delegate:self didFinish:@selector(didGetTag:) didFail:@selector(didFail:)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [markService cancelReadRequests];
    [tagService cancelReadRequests];
}

#pragma mark JTService

- (void)didGetTag:(NSDictionary*)dict
{
    destinationCoordinate.latitude = [[[dict objectForKey:@"destinationCoordinate"] objectForKey:@"lat"] floatValue];
    destinationCoordinate.longitude = [[[dict objectForKey:@"destinationCoordinate"] objectForKey:@"lon"] floatValue];
    
    currentAccuracy = [[dict objectForKey:@"destinationAccuracy"] intValue];

    destinationRange = [[JTDrawPickupRange alloc] initWithMapView:myMapView coordinate:destinationCoordinate sizeInMeters:currentAccuracy color:[UIColor blueColor]];
    [markService getAllForTag:myTagKey delegate:self didFinish:@selector(didLoadMarks:) didFail:@selector(didFail:)];
}

- (void)didLoadMarks:(NSDictionary*)dict
{
    NSDictionary *marks = [dict objectForKey:@"marks"];
    NSMutableArray *latList = [[NSMutableArray alloc] initWithCapacity:[marks count]];
    NSMutableArray *lonList = [[NSMutableArray alloc] initWithCapacity:[marks count]];

    for(NSDictionary *mark in marks)
    {
        NSNumber *lat = [NSNumber numberWithFloat:[[[mark objectForKey:@"coordinate"] objectForKey:@"lat"] floatValue]];
        NSNumber *lon = [NSNumber numberWithFloat:[[[mark objectForKey:@"coordinate"] objectForKey:@"lon"] floatValue]];
        [latList addObject:lat];
        [lonList addObject:lon];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [lat floatValue];
        coordinate.longitude = [lon floatValue];


        JTAnnotation2 *annotation = [[JTAnnotation2 alloc] initWithCoordinate:coordinate title:nil subtitle:nil];
        [myMapView addAnnotation:annotation];
        [annotation release];
    }    
    
    JTAnnotation2 *annotation = [[JTAnnotation2 alloc] initWithCoordinate:destinationCoordinate title:nil subtitle:nil];
    [myMapView addAnnotation:annotation];
    [annotation release];
    
    [route release];
    route = [[JTRouteLayerView alloc] initWithLatList:latList lonList:lonList mapView:myMapView lineColor:[UIColor blueColor] centerView:YES];    
    
    [latList release];
    [lonList release];
    
    [route setNeedsDisplay];
    [destinationRange setNeedsDisplay];
    [myMapView setRegion:route.region animated:YES]; //redundant and required: built in zoom starts and stops very quickly without it
}

- (void)didFail:(ASIHTTPRequest*)request
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't load from server" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [alertView show];
    [alertView release];  
}


#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    CLLocationCoordinate2D coordinate;
    coordinate = annotation.coordinate;
    
    if( coordinate.latitude == destinationCoordinate.latitude && coordinate.longitude == destinationCoordinate.longitude )
    {
        MKAnnotationView *finishView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"finish"] autorelease];
        ((JTAnnotation2*)annotation).title = @"Destination";  
        finishView.image = [UIImage imageNamed:@"FinishIcon2.png"];            
        
        return finishView;        
    } else {
        return [mapView viewForAnnotation:annotation];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    route.hidden = YES;
    destinationRange.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    route.hidden = NO;
    destinationRange.hidden = NO;
    
    [route setNeedsDisplay];
    [destinationRange setNeedsDisplay];
}

- (void)dealloc {
    [myTagKey release];
    [myMapView release];
    
    [route removeFromMapview];
    [route release];
    
    [destinationRange release];
        
    [markService release];
    [tagService release];
    
    [super dealloc];
}


@end
