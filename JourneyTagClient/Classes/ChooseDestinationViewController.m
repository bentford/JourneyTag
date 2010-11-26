//
//  ChooseDestinationViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 6/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChooseDestinationViewController.h"
#import "GreatCircleDistance.h"
#import "MapPipperView.h"

@interface ChooseDestinationViewController(PrivateMethods)
- (void)chooseDestinationAndDismissViewController:(id)sender;
@end

@implementation ChooseDestinationViewController
@synthesize defaultLocation, hasDefaultLocation;

- (id)init {
    if( self = [super init] ) {

    }
    return self;
}

- (void)viewDidLoad  {
    [super viewDidLoad];
	
    UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:@"Set Destination" style:UIBarButtonItemStyleBordered target:self action:@selector(chooseDestinationAndDismissViewController:)] autorelease];
    self.navigationItem.rightBarButtonItem = button;
	
	CGRect pipperFrame = {self.view.frame.size.width/2.0, self.view.frame.size.height/2.0, 20, 20};
	MapPipperView *pipper = [[[MapPipperView alloc] initWithFrame:pipperFrame] autorelease];
	[self.view addSubview:pipper];
}

- (void)viewDidUnload {
    
    self.navigationItem.rightBarButtonItem = nil;    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    if( hasDefaultLocation ) {
        CGFloat meters = [GreatCircleDistance milesToMeters:15];
        [myMapView setRegion:MKCoordinateRegionMakeWithDistance(defaultLocation, meters, meters) animated:YES];
    }    
}

- (void)dealloc {
 
	[super dealloc];
}


@end

@implementation ChooseDestinationViewController(PrivateMethods)
- (void)chooseDestinationAndDismissViewController:(id)sender {
    CLLocationCoordinate2D coordinate = [myMapView centerCoordinate];
	
    NSString *latString = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *lonString = [NSString stringWithFormat:@"%f",coordinate.longitude];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:latString,@"lat",lonString,@"lon",nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetDestinationCoordinate" object:self userInfo:info];
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end