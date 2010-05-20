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
#import "JTServiceURLs.h"
#import "PlaceMarkFormatter.h"
#import "DistanceTextUtil.h"

@interface PickupViewController()
@property (nonatomic, retain) NSString *selectedTagKey;
@property (nonatomic, retain) MKReverseGeocoder *geocoder;
@property (nonatomic, retain) NSTimer *geocodeTimeout;
@property (nonatomic, retain) NSMutableDictionary *annotationViews;
@end

@interface PickupViewController(PrivateMethods)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

- (void)showCustomTagCalloutView:(id<MKAnnotation>)annotation;
- (void)finishShowingCustomTagCalloutView:(NSTimer *)timer;
- (void)customTagCalloutAnimationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)hideCustomTagCallout;
- (void)finishedHidingCallout:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)showPickupInfoView:(JTAnnotation *)annotation;

- (void)didLoadCalloutImageData:(NSData *)data;
- (void)didFail:(ASIHTTPRequest *)request;

- (CGRect)getCalloutFrameForAnnotation:(id<MKAnnotation>)annotation;
- (void)pickupTag;
- (void)checkForFailedTagPickup:(NSDictionary *)dict;
- (JTAnnotation *)getJTAnnotationWithTagKey:(NSString *)tagKey;

- (void)moveTagDown:(id<MKAnnotation>)annotation;
- (void)retryCallout:(NSTimer *)timer;
@end

@implementation PickupViewController
@synthesize myMapView, selectedTagKey, geocoder, geocodeTimeout, annotationViews;

#define kTextViewTag 5
#define MOVE_ANIMATION_DURATION_SECONDS 0.5
#define kGeoCodeTimeout 5

- (void)awakeFromNib
{
    self.title = @"Pickup";
    tagService = [[JTTagService alloc] init];
    depotService = [[JTDepotService alloc] init];
    photoService = [[JTPhotoService alloc] init];
    
    hasPreviouslySelectedDepot = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushTagDetails) name:@"PushTagDetails" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToDepot:) name:@"MoveToDepot" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markWasTouched:) name:@"MarkWasTouched" object:nil];
    
    annotationViews = [[NSMutableDictionary alloc] initWithCapacity:0];
    isRunningHideAnimation = NO;
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

- (void)viewWillDisappear:(BOOL)animated {
    
    [self hideCustomTagCallout];
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
        
        [TagMapLoader removeAllJTAnnotationsFromMap:myMapView forType:JTAnnotationTypeDepot];
        
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
        // deprecated
        //pin.rightCalloutAccessoryView = button; 

        // used to override built in callout
        [pin addObserver:self
                    forKeyPath:@"selected"
                       options:NSKeyValueObservingOptionNew
                       context:@"PIN_ANNOTATION_SELECTED"];
        
        // keep track of view so we can remove the observer later on
        [annotationViews setObject:pin forKey:tag.key];
        return pin;
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    pickupRangeView.hidden = YES;
    
    if( [[myMapView selectedAnnotations] count] > 0 ) 
        customTagCallout.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    pickupRangeView.hidden = NO;
    [pickupRangeView setNeedsDisplay];
    
    if( [[myMapView selectedAnnotations] count] > 0 ) {
        
        customTagCallout.hidden = NO;

        id<MKAnnotation> annotation = [[myMapView selectedAnnotations] objectAtIndex:0];
        customTagCallout.frame = [self getCalloutFrameForAnnotation:annotation];
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

	// unobserve and clear tracked annotations views
	for( NSString *key in [self.annotationViews allKeys] ) {
        
        // skip selected tag
        if( [key isEqualToString:self.selectedTagKey] )
            continue;
        
        // clear observer
        JTAnnotation *annotation = [self.annotationViews objectForKey:key];
		[annotation removeObserver:self forKeyPath:@"selected"];
        
        // stop tracking 
        [self.annotationViews removeObjectForKey:key];
	}
    
	BOOL containsReachableTags = [TagMapLoader loadTags:myMapView tags:tags excludeSelectedTagKey:self.selectedTagKey];
    
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
        details.didPickupTagSelector = @selector(removeTagFromMap:);
        
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


- (void)removeTagFromMap:(NSString*)tagKey {     
    
    // 1) remove observer 
    TagAnnotationView *annotationView = [annotationViews objectForKey:tagKey];
    [annotationView removeObserver:self forKeyPath:@"selected"];
    
    // 2) remove from tracking dictionary
    [annotationViews removeObjectForKey:tagKey];
    
    // 3) remove annotation from map
    [TagMapLoader removeJTAnnotationFromMap:myMapView forTagKey:tagKey];
    
    // 4) dismiss callout - this method clears the selectedTagKey
    [self hideCustomTagCallout];
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

    // confirm tag pickup
    UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Confirm Pickup",@"Cancel",nil];
    confirm.destructiveButtonIndex = 0;
    confirm.actionSheetStyle = UIActionSheetStyleDefault;
    [confirm showInView:self.tabBarController.view];
    [confirm release];
}

- (IBAction)moreInfoAction:(id)sender {
    
    JTAnnotation *annotation = [self getJTAnnotationWithTagKey:self.selectedTagKey];
    
    PickupTagDetailsTableViewController *details = [[PickupTagDetailsTableViewController alloc] init];
    details.tagKey = self.selectedTagKey;    
    details.withinPickupRange = annotation.withinPickupRange;
    details.currentLocation = currentLocation;
    details.hasLocation = hasLocation || hasPreviouslySelectedDepot;
    details.pickupDelegate = self;
    details.didPickupTagSelector = @selector(removeTagFromMap:);
    
    details.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:details animated:YES];    
    [details release];    
}

#pragma mark -

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if( buttonIndex == 0)
        [self pickupTag];
}
#pragma mark -

#pragma mark MKReverseGeocoderDelegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    [self.geocodeTimeout invalidate];
    
    destinationNameLabel.text = [PlaceMarkFormatter standardFormat:placemark];
    destinationNameLabel.font = [UIFont systemFontOfSize:12];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    [self.geocodeTimeout invalidate];
    
    destinationNameLabel.text = [NSString stringWithFormat:@"Geocode Server Overloaded"];
    destinationNameLabel.font = [UIFont boldSystemFontOfSize:12];
    //NSLog(@"geocode error: %@", [error localizedDescription]);
}

- (void)geocodeTimedOut:(NSTimer *)timer {
    destinationNameLabel.text = @"Geocode Server Overloaded";
    destinationNameLabel.font = [UIFont boldSystemFontOfSize:12];
}

#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if( touch.view == customTagCallout )
        NSLog(@"touched callout");
}

#pragma mark other
- (void)dealloc {
    [myMapView release];
    [tagService release];
    [locManager release];
    [pickupRangeView release];
    [annotationViews release];
    
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
            shouldAnimateCallout = (self.selectedTagKey == nil);
            NSLog(@"showing callout");
			[self showCustomTagCalloutView:pin.annotation];
        } else 
            NSLog(@"hiding callout");
			[self hideCustomTagCallout];
	}
}

- (void)moveTagDown:(id<MKAnnotation>)annotation {
    // goal is to center on a point 100px above the tag
    // calculate latitudes per pixel
    CGFloat latitudesPerPixel = myMapView.region.span.latitudeDelta / myMapView.frame.size.height;
    
    // calculate target latitude, 100px above the tag
    CGFloat targetLatitude = annotation.coordinate.latitude + (latitudesPerPixel * 100);
    
    // calculate target longitude, offset from current center
    CGFloat targetLongitude = 0;
    if( annotation.coordinate.longitude > myMapView.centerCoordinate.longitude )
        targetLongitude = annotation.coordinate.longitude - (annotation.coordinate.longitude - myMapView.centerCoordinate.longitude);
    else 
        targetLongitude = annotation.coordinate.longitude + (myMapView.centerCoordinate.longitude - annotation.coordinate.longitude);
    
    //create target coordinate 
    CLLocationCoordinate2D targetCoordinate = {targetLatitude, targetLongitude}; 
    
    //center map on this point
    [myMapView setCenterCoordinate:targetCoordinate animated:YES];    
}

- (void)retryCallout:(NSTimer *)timer {
    id<MKAnnotation> annotation = (id<MKAnnotation>)timer.userInfo;
    [self showCustomTagCalloutView:annotation];
}

- (void)showCustomTagCalloutView:(id<MKAnnotation>)annotation {
    
    if( isRunningHideAnimation) {
        [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(retryCallout:) userInfo:annotation repeats:NO];
        return;
     }
    
    isRunningShowAnimation = YES;
    [self moveTagDown:annotation];
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(finishShowingCustomTagCalloutView:) userInfo:annotation repeats:NO];
    
}

- (void)finishShowingCustomTagCalloutView:(NSTimer *)timer {
    
    JTAnnotation *tagAnnotation = (JTAnnotation *)timer.userInfo;
    
    [[NSBundle mainBundle] loadNibNamed:@"TagCalloutView" owner:self options:nil];
    
    customTagCallout.frame = [self getCalloutFrameForAnnotation:tagAnnotation];
    calloutTitle.text = tagAnnotation.title;
    calloutDestinationDirection.text = tagAnnotation.subtitle;
    [calloutActivity startAnimating];
    
    //if( shouldAnimateCallout ) {
        customTagCallout.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [self.view addSubview:customTagCallout];
        
        [UIView beginAnimations:@"expand_callout" context:tagAnnotation];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(customTagCalloutAnimationFinished:finished:context:)];
        
        customTagCallout.transform = CGAffineTransformMakeScale(1, 1);
        
        [UIView commitAnimations];
    //} else {
        //[self customTagCalloutAnimationFinished:nil finished:nil context:tagAnnotation];
    //}
}

- (void)customTagCalloutAnimationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {

    JTAnnotation *tagAnnotation = (JTAnnotation *)context;
    
    [self showPickupInfoView:tagAnnotation];
    
    // need this for picking up tag
    self.selectedTagKey = tagAnnotation.key;
    
    [photoService getImageDataWithTagKey:tagAnnotation.key delegate:self didFinish:@selector(didLoadCalloutImageData:) didFail:@selector(didFail:)];   
}

- (void)hideCustomTagCallout {
    
    isRunningHideAnimation = YES;
    NSLog(@"hiding now");
    [UIView beginAnimations:@"hide_callout_and_pickup_info" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishedHidingCallout:finished:context:)];
    
    pickupInfoView.transform = CGAffineTransformMakeTranslation(0, pickupInfoView.frame.size.height * -1);
    customTagCallout.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView commitAnimations];
}

- (void)finishedHidingCallout:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [customTagCallout removeFromSuperview]; //not retained so it dies
    customTagCallout = nil;
    
    [pickupInfoView removeFromSuperview];
    pickupInfoView = nil;   
    
    // clear tag selection
    self.selectedTagKey = nil;
    
    isRunningHideAnimation = NO;
}

- (void)showPickupInfoView:(JTAnnotation *)annotation {
    [[NSBundle mainBundle] loadNibNamed:@"PickupInfoView" owner:self options:nil];
    
	[[NSBundle mainBundle] loadNibNamed:@"DistanceMeterView" owner:self options:nil];
	distanceMeterView.frame = CGRectMake(0, 0, distanceMeterContainer.frame.size.width, distanceMeterContainer.frame.size.height);
	[distanceMeterContainer addSubview:distanceMeterView];
	distanceTraveledLabel.text = annotation.progressMeterText;
    
    // TODO: abstract this into a view
    CGFloat width = (annotation.distanceTraveled/annotation.totalDistance) * distanceMeterContainer.frame.size.width;
    CGFloat adjustedWidth = fmax(width,25); //don't go smaller than endcap

    progressGreen.frame = CGRectMake(progressGreen.frame.origin.x, progressGreen.frame.origin.y, adjustedWidth, progressGreen.frame.size.height);
	[self.view addSubview:pickupInfoView];
    
	pickupButton.enabled = annotation.withinPickupRange;
	if( annotation.withinPickupRange ) {
		[pickupButton setTitle:@"Pickup Tag" forState:UIControlStateNormal];
	} else {
		[pickupButton setTitle:@"" forState:UIControlStateNormal];
	}
	
    // adding the pickupview above navigation controller
    pickupInfoView.frame = CGRectMake(0, 0+20, pickupInfoView.frame.size.width, pickupInfoView.frame.size.height);
    
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [window addSubview:pickupInfoView];
    
    //if( shouldAnimateCallout ) {
        pickupInfoView.transform = CGAffineTransformMakeTranslation(0, pickupInfoView.frame.size.height * -1);
        [UIView beginAnimations:@"show_pickup_info" context:annotation];
        [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didFinishShowing:::)];
        pickupInfoView.transform = CGAffineTransformMakeTranslation(0, 0);
        
        [UIView commitAnimations];
    //}
    
    self.geocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:annotation.destinationCoordinate] autorelease];
    self.geocoder.delegate = self;
    [self.geocoder start];
    
    destinationNameLabel.text = @"Loading...";
    [self.geocodeTimeout invalidate];
    self.geocodeTimeout = [NSTimer scheduledTimerWithTimeInterval:kGeoCodeTimeout target:self selector:@selector(geocodeTimedOut:) userInfo:nil repeats:NO];
}

- (void)didFinishShowing:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    isRunningShowAnimation = NO;
}

- (void)didLoadCalloutImageData:(NSData *)data {

    calloutImage.image = [UIImage imageWithData:data];
    [calloutActivity stopAnimating];
}

- (void)didFail:(ASIHTTPRequest *)request {
    NSLog(@"request failed");
    [calloutActivity stopAnimating];
}


- (CGRect)getCalloutFrameForAnnotation:(id<MKAnnotation>)annotation {

    CGPoint pinLocation = [myMapView convertCoordinate:annotation.coordinate toPointToView:self.view];
    return CGRectMake(round(pinLocation.x) - 50, 
                      round(pinLocation.y) - 20 - customTagCallout.frame.size.height, 
                      customTagCallout.frame.size.width,
                      customTagCallout.frame.size.height);
}

- (void)pickupTag {

    [tagService pickup:self.selectedTagKey delegate:self didFinish:@selector(checkForFailedTagPickup:) didFail:@selector(didFail:)]; 
}

- (void)checkForFailedTagPickup:(NSDictionary *)dict {
    

    NSString *tagKey = [dict objectForKey:@"tagKey"];
    if( [tagKey isEqualToString:@"False"] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too slow" message:@"Another player picked up this tag before you could." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release]; 
    } 
    
    [self removeTagFromMap:tagKey];
}

- (JTAnnotation *)getJTAnnotationWithTagKey:(NSString *)tagKey {
    int count = [myMapView.annotations count];
    for( int i = 0; i < count; i++ )
    {
        id<MKAnnotation> ob = [myMapView.annotations objectAtIndex:i];
        if( [ob isKindOfClass:[JTAnnotation class]] )
        {
            JTAnnotation *annotation = (JTAnnotation*)ob;
            if( [annotation.key isEqualToString:self.selectedTagKey] )
                return annotation;
        }
    }   
    return nil;
}
@end
