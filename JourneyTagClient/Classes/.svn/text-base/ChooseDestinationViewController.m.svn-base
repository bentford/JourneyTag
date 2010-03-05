//
//  ChooseDestinationViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 6/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChooseDestinationViewController.h"
#import "GreatCircleDistance.h"

@implementation ChooseDestinationViewController
@synthesize defaultLocation, hasDefaultLocation;

- (id)init
{
    self = [super init];
    
    myMapView.delegate = self;
    myMapView.showsUserLocation = YES;
    
    return self;
}

- (void)viewDidLoad 
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Set Destination" style:UIBarButtonItemStyleBordered target:self action:@selector(setDestination:)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];

    layer = [[MapTouchLayer alloc] initWithMapView:myMapView]; //must load here
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [layer removeFromSuperview];
    [layer release];
    
    self.navigationItem.rightBarButtonItem = nil;    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    if( hasDefaultLocation )
    {
        float meters = [GreatCircleDistance milesToMeters:15];
        [myMapView setRegion:MKCoordinateRegionMakeWithDistance(defaultLocation, meters, meters) animated:YES];
    }    
}

- (void) setDestination:(id)sender
{
    CLLocationCoordinate2D coordinate = [myMapView centerCoordinate];

    NSString *latString = [[NSString alloc] initWithFormat:@"%f",coordinate.latitude];
    NSString *lonString = [[NSString alloc] initWithFormat:@"%f",coordinate.longitude];
    
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:latString,@"lat",lonString,@"lon",nil];
    [latString release];
    [lonString release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetDestinationCoordinate" object:self userInfo:info];
    [info release];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    myMapView.showsUserLocation = NO;
    
    [myMapView release];
    [layer release];
    [super dealloc];
}


@end
