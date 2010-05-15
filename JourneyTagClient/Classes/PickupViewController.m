//
//  PickupViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 4/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PickupViewController.h"

#import "ActivityButtonUtil.h"
#import "DepotDetailsTableViewController.h"
#import "MapViewUtil.h"
#import "JTAnnotation.h"
#import "DepotAnnotationView.h"
#import "TagAnnotationView.h"
#import "GreatCircleDistance.h"
#import "PickupTagDetailsTableViewController.h"
#import "AppSettings.h"

@interface PickupViewController(PrivateMethods)
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;

- (void)showCustomCalloutView:(id<MKAnnotation>)annotation;
- (void)hideCustomAnnotation;
- (void)showPickupInfoView;
- (void)hidePickupInfoView;
@end

@implementation PickupViewController
@synthesize myMapView;

#define kCustomCalloutView 100
#define kTextViewTag 5
#define MOVE_ANIMATION_DURATION_SECONDS 0.5

- (void)awakeFromNib
{
    self.title = @"Pickup";
    tagService = [[JTTagService alloc] init];
    depotService = [[JTDepotService alloc] init];
    
    hasPreviouslySelectedDepot = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushTagDetails) name:@"PushTagDetails" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToDepot:) name:@"MoveToDepot" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markWasTouched:) name:@"MarkWasTouched" object:nil];
}

#pragma mark  init
- (void) viewDidLoad
{   
    //map setup
    myMapView.delegate = self;    
    myMapView.showsUserLocation = YES;
    
    currentViewCoordinate = myMapView.centerCoordinate;
    currentLocation = myMapView.centerCoordinate;
    
    //green circle
    pickupRangeView = [[JTDrawPickupRange alloc] initWithMapView:myMapView sizeInMeters:[AppSettings pickupRangeInMeters]];
    pickupRangeView.hidden = YES;

    //UI Setup

    self.navigationItem.titleView = [self createSegment];
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createRefreshButton:self action:@selector(loadTagsForCurrentLocation:)];
    [self addGotoButton]; //sets rightBarButtonItem
    
    //message pop-down
    messageView = [[UIView alloc] initWithFrame:CGRectMake(0, -45, 320, 45)];
    messageView.backgroundColor = [UIColor clearColor];
    
    UIImageView *bar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AnimatedBarOrange.png"]];
    bar.frame = CGRectMake(10, 0, 300, 45);
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(20, -3, 280, 45)];
    text.backgroundColor = [UIColor clearColor];
    text.editable = NO;
    text.scrollEnabled = NO;
    text.font = [UIFont boldSystemFontOfSize:14.0];
    text.textAlignment = UITextAlignmentCenter;
    text.tag = kTextViewTag;
    
    [messageView addSubview:bar];
    [messageView addSubview:text];
    [self.view addSubview:messageView];

    [text release];
    [bar release];
    
    //first thing the pickup screen should do
    [self gotoButtonPressed:nil];
    
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    //map teardown
    myMapView.delegate = nil;
    
    //green circle
    [pickupRangeView release];
    pickupRangeView = nil;

    //UI Teardown
    self.navigationItem.titleView = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    [messageView release];
    messageView = nil;
    
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self startLocationManager];
    
    [self createScrollCheckTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //[locManager stopUpdatingLocation]; //this breaks picking up depots, don't use it!!
    [mapRefreshTimer invalidate];
}

- (void) startLocationManager
{
    if( locManager == nil ) 
    {
        locManager = [[CLLocationManager alloc] init];
        locManager.distanceFilter = [AppSettings distanceFilter];
        locManager.desiredAccuracy = [AppSettings desiredAccuracy];
        locManager.delegate = self;
    }
    [locManager startUpdatingLocation];
}

- (void) stopLocationManager
{
    if( locManager != nil )
    {
        [locManager stopUpdatingLocation];
    }
}

- (UISegmentedControl*) createSegment
{
    NSArray *items = [[NSArray alloc] initWithObjects:@"Near You",@"Near Depots",nil];
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:items];
    [items release];
    
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    segment.selectedSegmentIndex = 0;
    
    [segment addTarget:self action:@selector(changedMapType:) forControlEvents:UIControlEventValueChanged];
    [segment autorelease];
    
    return segment;
}

- (void) changedMapType:(id)sender
{
    [self setMapType:[sender selectedSegmentIndex]];
}

- (void)setMapType:(int)typeNumber
{
    if( typeNumber == 0 )
    {
        myMapView.showsUserLocation = YES;
        
        [pickupRangeView useCurrentLocation];
        [pickupRangeView setNeedsDisplay];
        followCurrentLocation = YES;
        
        [self startLocationManager];
        
        [TagMapLoader removeJTAnnotationFromMap:myMapView forType:JTAnnotationTypeDepot];
        
        currentLocation = locManager.location.coordinate;
        [self addGotoButton];
        
    } else if( typeNumber == 1 )
    {
        [pickupRangeView setNeedsDisplay];
        [self stopLocationManager];
        followCurrentLocation = NO;
        
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStyleBordered target:self action:@selector(showDepotIndex)];
        self.navigationItem.rightBarButtonItem = button;
        [button release];
        
        if( hasPreviouslySelectedDepot )
        {
            
            
            [self loadDepotOntoMap:lastSelectedDepot];
            
        } else {
            [self showDepotIndex];
        }
    }
    
    [self gotoCurrentLocation];
}

- (void) addGotoButton
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TargetIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = button;
    [button release];    
}

- (void) showDepotIndex
{
    DepotIndexTableViewController *controller = [[DepotIndexTableViewController alloc] initWithDelegate:self didSelectDepot:@selector(didChooseDepot:)];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (void)didChooseDepot:(NSDictionary*)depot
{
    [self dismissModalViewControllerAnimated:YES];
    
    if( [depot isKindOfClass:[NSString class]] ) //if server returned error string
    {
        UISegmentedControl *segment = (UISegmentedControl*) self.navigationItem.titleView;
        segment.selectedSegmentIndex = 0;
        return;
    }
    [self loadDepotOntoMap:depot];

    if( lastSelectedDepot )
        [lastSelectedDepot release];
    lastSelectedDepot = [depot retain];  

    [self createScrollCheckTimer]; //timer stops after showing the DepotIndexView
    [self gotoCurrentLocation];
}

- (void)loadDepotOntoMap:(NSDictionary*)depot
{
    myMapView.showsUserLocation = NO;  //this gets in the way of depots
    
    double lat = [[[depot objectForKey:@"coordinate"] objectForKey:@"lat"] doubleValue];
    double lon = [[[depot objectForKey:@"coordinate"] objectForKey:@"lon"] doubleValue];
    
    currentLocation.latitude = lat;
    currentLocation.longitude = lon;    
    hasPreviouslySelectedDepot = YES;
    
    if( lastSelectedDepot )
        [lastSelectedDepot release];
    lastSelectedDepot = [depot retain];  
    
    currentViewCoordinate = currentLocation;
    
    [TagMapLoader loadDepot:myMapView dictionary:depot];
    [self loadTagsForCurrentLocation:nil];
    

    
    [pickupRangeView useCustomCoordinate:currentLocation];
}

#pragma mark mapScrollCheck
- (void) createScrollCheckTimer
{
    BOOL createTimer = NO;

    if( mapRefreshTimer == nil )
    {
        createTimer = YES;
    } 
    else 
    {
        if( ![mapRefreshTimer isValid] )
        {
            createTimer = YES;
        }        
    }
    
    if( createTimer )
    {
        [mapRefreshTimer release]; //allowed even if nil
        mapRefreshTimer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(mapScrollCheck:) userInfo:nil repeats:YES];
        [mapRefreshTimer retain];
        [[NSRunLoop currentRunLoop] addTimer:mapRefreshTimer forMode:NSDefaultRunLoopMode];
    }
    
}

- (void) mapScrollCheck:(id)sender
{
    float distance = [GreatCircleDistance distance:currentViewCoordinate second:myMapView.centerCoordinate];
    
    if( distance > [AppSettings refreshOnScrollDistanceInMiles] ) 
    {
        currentViewCoordinate = myMapView.centerCoordinate;
        [self loadTagsForCurrentLocation:nil];
        followCurrentLocation = NO;
    }
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    if( [annotation isKindOfClass:[MKUserLocation class]] )
    {
        return nil; //use system default
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:annotation action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    
    JTAnnotation *tag = (JTAnnotation*)annotation;
    if( tag.type == JTAnnotationTypeDepot )
    {
        DepotAnnotationView *depot = [[[DepotAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"depot"] autorelease];
        depot.canShowCallout = YES;
        depot.rightCalloutAccessoryView = button;
        return depot;
    } else {
        TagAnnotationView *pin = [[[TagAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];
        
        pin.canShowCallout = YES;
        pin.rightCalloutAccessoryView = button;

        // used to override built in callout
        [pin addObserver:self
                    forKeyPath:@"selected"
                       options:NSKeyValueObservingOptionNew
                       context:@"PIN_ANNOTATION_SELECTED"];
        
        return pin;
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    pickupRangeView.hidden = YES;
    
    if( [[myMapView selectedAnnotations] count] > 0 ) 
        [self.view viewWithTag:kCustomCalloutView].hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    pickupRangeView.hidden = NO;
    [pickupRangeView setNeedsDisplay];
    
    if( [[myMapView selectedAnnotations] count] > 0 ) {
        UIView *customCalloutView = [self.view viewWithTag:kCustomCalloutView];
        customCalloutView.hidden = NO;

        id<MKAnnotation> annotation = [[myMapView selectedAnnotations] objectAtIndex:0];
        CGPoint pinLocation = [myMapView convertCoordinate:annotation.coordinate toPointToView:self.view];
        customCalloutView.center = CGPointMake(pinLocation.x+20, pinLocation.y-(customCalloutView.frame.size.height/2 + 25));
    }
    
}

#pragma mark MapLoading
- (void) gotoButtonPressed:(id)sender
{
        followCurrentLocation = YES;
        self.navigationItem.rightBarButtonItem = [ActivityButtonUtil createActivityIndicatorButton];
        [self startRefreshTimer];

        [self gotoCurrentLocation];

}

- (void) gotoCurrentLocation
{

    if( currentLocation.latitude != 0 )
    {
        float meters = [GreatCircleDistance milesToMeters:12];
        myMapView.region = MKCoordinateRegionMakeWithDistance(currentLocation,meters,meters);
    }

}

- (void) loadTagsForCurrentLocation:(id)sender
{
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createActivityIndicatorButton];
    [tagService getForCoordinate:currentViewCoordinate.latitude viewLon:currentViewCoordinate.longitude physicalLat:currentLocation.latitude physicalLon:currentLocation.longitude delegate:self didFinish:@selector(didLoadTags:) didFail:@selector(didFail:)];
}

- (void) didLoadTags:(NSDictionary*)dict
{
    NSArray *tags = [dict objectForKey:@"tags"];
    BOOL containsReachableTags = [TagMapLoader loadTags:myMapView tags:tags]; 
    
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createRefreshButton:self action:@selector(loadTagsForCurrentLocation:)];

    NSString *message = nil;
    if( [tags count] == 0  ) {
        message = [[NSString alloc] initWithFormat:@"%@",@"No tags are here.  NOTE: view range is 25 miles from center of screen."];
    } else if( ![MapViewUtil tagsAreVisibleForMapView:myMapView] ) {
        message = [[NSString alloc] initWithFormat:@"%@",@"Zoom out to see nearby tags"];
    } else if( !containsReachableTags ) {
        message = [[NSString alloc] initWithFormat:@"%@",@"Get closer to the red tags to pick them up."];
    }
    
    if( message == nil ) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:MOVE_ANIMATION_DURATION_SECONDS];
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, -44);
        messageView.transform = transform;
        
        [UIView commitAnimations];
        messageVisible = NO;
    } else {
        UITextView *textView = (UITextView*)[messageView viewWithTag:kTextViewTag];
        textView.text = message;
        [textView setNeedsDisplay];
        [messageView setNeedsDisplay];
        if( !messageVisible ) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:MOVE_ANIMATION_DURATION_SECONDS];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 44);
            messageView.transform = transform;
            
            [UIView commitAnimations];
            messageVisible = YES;
        }
    }
    [message release];
}

#pragma mark map actions

- (void) markWasTouched:(NSNotification*)notification
{
    NSDictionary *data = [notification userInfo];
    int type = [[data objectForKey:@"type"] intValue];
    if(type == JTAnnotationTypeTag )
    {
        BOOL withinPickupRange = [[data objectForKey:@"withinPickupRange"] boolValue];
        
        PickupTagDetailsTableViewController *details = [[PickupTagDetailsTableViewController alloc] init];
        details.tagKey = [data objectForKey:@"key"];    
        details.withinPickupRange = withinPickupRange;
        details.currentLocation = currentLocation;
        details.hasLocation = hasLocation || hasPreviouslySelectedDepot;
        details.pickupDelegate = self;
        details.didPickupTagSelector = @selector(didPickupTag:);
        
        details.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:details animated:YES];    
        [details release];
    } else {
        DepotDetailsTableViewController *childController = [[DepotDetailsTableViewController alloc] initWithDepotKey:[data objectForKey:@"key"]];
        childController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:childController animated:YES];    
        [childController release];

        if( lastSelectedDepot ) 
        {
            NSString *lastSelectedDepotKey = [lastSelectedDepot objectForKey:@"key"];
            NSString *thisSelectedDepotKey = [data objectForKey:@"key"];            
            if( [lastSelectedDepotKey compare:thisSelectedDepotKey] == NSOrderedSame)
            {
                [lastSelectedDepot release];
                lastSelectedDepot = nil;
                hasPreviouslySelectedDepot = NO;
            }
        }
        
        UISegmentedControl *segment = (UISegmentedControl*)self.navigationItem.titleView;
        segment.selectedSegmentIndex = 0;
        [self changedMapType:segment];
    }
}

- (void)didPickupTag:(NSString*)tagKey
{    
    int count = [myMapView.annotations count];
    
    NSMutableArray *removeList = [[NSMutableArray alloc] initWithCapacity:count];
    
    for( int i = 0; i < count; i++ )
    {
        id<MKAnnotation> ob = [myMapView.annotations objectAtIndex:i];
        if( [ob isKindOfClass:[JTAnnotation class]] )
        {
            JTAnnotation *annotation = (JTAnnotation*)ob;
            if( [annotation.key compare:tagKey] == NSOrderedSame )
            {
                [removeList addObject:annotation];

            }
        }
    }
    
    for( JTAnnotation *annotation in removeList)
    {
        [myMapView removeAnnotation:annotation];
    }
    [removeList release];
}

#pragma mark CLLocationManager
- (void) locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation
{
    if( hasPreviouslySelectedDepot ) 
    {
        return; //absolutely neccessary!  turning off updates when viewing depots doesn't stop this method from running.
    }
    currentLocation = newLocation.coordinate;
    hasLocation = YES;
    
    if( followCurrentLocation )
    {
        [self startRefreshTimer];
        [self gotoCurrentLocation];
    }
    
    [pickupRangeView setNeedsDisplay];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    if( hasPreviouslySelectedDepot )
    {
        return;
    }
    hasLocation = NO;
    
    NSString *message = @"Could not get current location.  You cannot pickup tags or depots until the app knows where you are";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark Refresh Timer

- (void) startRefreshTimer
{
    if( locationRefreshTimer != nil )
    {
        [locationRefreshTimer invalidate];
        [locationRefreshTimer release];
        locationRefreshTimer = nil;
    }
    locationRefreshTimer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(stopShowingRefresh:) userInfo:nil repeats:NO];
    [locationRefreshTimer retain];
    
    [[NSRunLoop currentRunLoop] addTimer:locationRefreshTimer forMode:NSDefaultRunLoopMode];
}

- (void) stopShowingRefresh:(id)sender
{
    [self addGotoButton];
}

#pragma mark PickupInfoView 
- (IBAction)pickupTagAction:(id)sender {
    
}

- (IBAction)moreInfoAction:(id)sender {
    
}

#pragma mark -

#pragma mark other
- (void)dealloc {
    [myMapView release];
    [tagService release];
    [locManager release];
    [pickupRangeView release];
    
    [super dealloc];
}
@end

@implementation PickupViewController(PrivateMethods)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSString *action = (NSString*)context;
	MKAnnotationView *pin = (MKAnnotationView *)object;    
    
    if([action isEqualToString:@"PIN_ANNOTATION_SELECTED"]){
		BOOL annotationAppeared = [[change valueForKey:@"new"] boolValue];
		if (annotationAppeared) {

			NSLog(@"annotation selected %@", pin.annotation.title);
			[self showCustomCalloutView:pin.annotation];
		}
		else {
			NSLog(@"annotation deselected %@", pin.annotation.title);
			[self hideCustomAnnotation];
		}
	}
}

- (void)showCustomCalloutView:(id<MKAnnotation>)annotation {
    
    CGPoint pinLocation = [myMapView convertCoordinate:annotation.coordinate toPointToView:self.view];
    NSLog(@"pin location: %f, %f", pinLocation.x, pinLocation.y);
    
    NSArray *parts = [[NSBundle mainBundle] loadNibNamed:@"PickupAnnotationView" owner:nil options:nil];
    UIView *customAnnotationView = [parts objectAtIndex:0];
    
    customAnnotationView.center = CGPointMake(pinLocation.x+20, pinLocation.y-(customAnnotationView.frame.size.height/2 + 25));
    customAnnotationView.tag = kCustomCalloutView;
    [self.view addSubview:customAnnotationView];
    
    [self showPickupInfoView];
    
}

- (void)hideCustomAnnotation {
    [[self.view viewWithTag:100] removeFromSuperview];
}

- (void)showPickupInfoView {
    [[NSBundle mainBundle] loadNibNamed:@"PickupInfoView" owner:self options:nil];
    [self.view addSubview:pickupInfoView];
    //pickupInfoView.frame = CGRectMake(0, -50, pickupRangeView.frame.size.width, pickupRangeView.frame.size.height);
    pickupInfoView.center = CGPointMake(pickupInfoView.center.x, pickupInfoView.center.y+20);
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [window addSubview:pickupInfoView];
}

- (void)hidePickupInfoView {
    [pickupInfoView release];
}
@end
