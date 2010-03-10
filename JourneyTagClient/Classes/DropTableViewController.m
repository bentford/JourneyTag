//
//  DropTableViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DropTableViewController.h"
#import "DepotTableViewController.h"
#import "DropTagDetailsTableViewController.h"
#import "ActivityButtonUtil.h"
#import "ImageResizeOperation.h"
#import "GreatCircleDistance.h"
#import "TableCellUtil.h"
#import "HelpViewController.h"
#import "AppSettings.h"
#import "AppFiles.h"
#import "FakeImagePickerViewController.h"
#import "ImageResize.h"
#import "LogUtil.h"

#define kTagView 0
#define kDepotView 1

@implementation DropTableViewController

- (void)awakeFromNib
{
    self.title = @"Drop";
    
    list = [[NSArray alloc] initWithObjects:@"Loading...", nil];
    depotList = [[NSArray alloc] initWithObjects:@"Loading...",nil];
    
    subtitleColorList = [[NSMutableArray alloc] initWithObjects:[AppSettings subtitleColorStandard], nil];
    subtitleList = [[NSMutableArray alloc] initWithObjects:@"",nil];
    
    hasTags = NO;
 
    depotService = [[JTDepotService alloc] init];
    inventoryService = [[JTInventoryService alloc] init];
    tagService = [[JTTagService alloc] init];
    
    viewMode = kTagView;
    
    queue = [[NSOperationQueue alloc] init];
    
    hasLocation = NO;
    dropAndPickup = NO;
    
    skipAutoRefresh = NO;
    
    dropSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:[AppFiles pathForDropSettings]];
    if( !dropSettings )
        dropSettings = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveDropSettings:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];

    [super awakeFromNib];
}

- (void)viewDidLoad 
{
    self.navigationItem.titleView = [self createSegment];
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createRefreshButton:self action:@selector(refreshData:)];
    self.navigationItem.rightBarButtonItem = [self makeToggleButton];
    
    [self startLocationManager];
    
    subtitleMode = [[dropSettings objectForKey:[LogUtil logKeyForString:@"detailMode"]] intValue];
    
    destinationImage =  [[UIImage imageNamed:@"CircleCheckered.png"] retain];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.navigationItem.titleView = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [locManager stopUpdatingLocation];
    [locManager release];
    locManager = nil;
    
    [destinationImage release];
    destinationImage = nil;
    
    [super viewDidUnload];
}


- (void)saveDropSettings:(id)sender
{
    [dropSettings writeToFile:[AppFiles pathForDropSettings] atomically:YES];
}

#pragma mark Toggle Detail Mode
- (void)toggleSubtitleText:(id)sender
{
    subtitleMode = (DropSubtitleMode)[self incrementMode:subtitleMode];
    [dropSettings setObject:[NSNumber numberWithInt:subtitleMode] forKey:[LogUtil logKeyForString:@"detailMode"]];
    
    [self updateSubtitleMode];
}

- (int)incrementMode:(DropSubtitleMode)mode
{
    int temp = (int)mode;
    temp += 1;

    if( temp > 2 )
        temp = 0;

    return (DropSubtitleMode)temp;
}


- (void)updateSubtitleMode
{
    switch (subtitleMode) {
        case DropSubtitleModeMovedDistance:
            [self updateMovedDistance];
            break;
        case DropSubtitleModeGainLossDistance:
            [self updateGainLossDistance];
            break;
        case DropSubtitleModeDestinationDistance:
            [self updateDestinationDistance];
            break;
    }
    [self updateStatusIcon];
    [self.tableView reloadData];
}

- (void)updateStatusIcon
{
    if( !coordinateList )
        return;
    
    if( showImageList )
        [showImageList release];
    showImageList = [[NSMutableArray alloc] initWithCapacity:[coordinateList count]];    
    
    for(int i = 0; i < [coordinateList count]; i++ )
        [showImageList addObject:[NSNumber numberWithBool:NO]];
    
    int index = 0;
    for(NSDictionary *destCoordDict in destinationCoordinateList)
    {
        CLLocationCoordinate2D destinationCoordinate;
        destinationCoordinate.latitude = [[destCoordDict objectForKey:@"lat"] floatValue];
        destinationCoordinate.longitude = [[destCoordDict objectForKey:@"lon"] floatValue]; 
        
        int distanceInMeters = [GreatCircleDistance distanceInMeters:currentLocation.coordinate second:destinationCoordinate];    
        
        int currentAccuracy = [[currentAccuracyList objectAtIndex:index] intValue];
        if( distanceInMeters <=  currentAccuracy ) 
            [showImageList replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
        
        index++;
    }
}

- (void)updateDestinationDistance
{
    if( !coordinateList )
        return;
    if( subtitleList )
        [subtitleList release];
    subtitleList = [[NSMutableArray alloc] initWithCapacity:[coordinateList count]];
    
    if( subtitleColorList )
        [subtitleColorList release];
    subtitleColorList = [[NSMutableArray alloc] initWithCapacity:[coordinateList count]];
    
    for(int i = 0; i < [coordinateList count]; i++ )
        [subtitleColorList addObject:[AppSettings subtitleColorStandard]];
    
    int index = 0;
    int distanceInMeters = 0;
    for(NSDictionary *destCoordDict in destinationCoordinateList)
    {
        CLLocationCoordinate2D destinationCoordinate, location;
        destinationCoordinate.latitude = [[destCoordDict objectForKey:@"lat"] floatValue];
        destinationCoordinate.longitude = [[destCoordDict objectForKey:@"lon"] floatValue]; 
        
        location = currentLocation.coordinate;
        
        distanceInMeters = [GreatCircleDistance distanceInMeters:location second:destinationCoordinate];
        NSString *bearing = [GreatCircleDistance getBearingNameFromDegrees:[GreatCircleDistance getBearingFromCoordinate:location toCoordinate:destinationCoordinate]];
        float distanceInMiles = [GreatCircleDistance metersToMiles:distanceInMeters];
        
        int currentAccuracy = [[currentAccuracyList objectAtIndex:index] intValue];
        if( distanceInMeters <=  currentAccuracy )
            [subtitleColorList replaceObjectAtIndex:index withObject:[AppSettings subtitleColorPositive]];    
                
        NSString *distanceText;
        if( distanceInMiles < 0.25 )
            distanceText = [[NSString alloc] initWithFormat:@"destination is %d yards to the %@ ",distanceInMeters, bearing];
        else
            distanceText = [[NSString alloc] initWithFormat:@"destination is %1.2f miles to the %@ ",distanceInMiles, bearing];
        
        [subtitleList addObject:distanceText];
        [distanceText release];
        
        index++;
    }
}

- (void)updateGainLossDistance
{
    if( !coordinateList )
        return;
    if( subtitleList )
        [subtitleList release];
    subtitleList = [[NSMutableArray alloc] initWithCapacity:[coordinateList count]];
    
    if( subtitleColorList )
        [subtitleColorList release];
    subtitleColorList = [[NSMutableArray alloc] initWithCapacity:[coordinateList count]];
    for(int i = 0; i < [coordinateList count]; i++ )
        [subtitleColorList addObject:[AppSettings subtitleColorStandard]];
    
    int index = 0;
    float markDistance = 0;
    float currentDistance = 0;
    float delta = 0;
    NSString *gainedLost;
    for(NSDictionary *destCoordDict in destinationCoordinateList)
    {
        CLLocationCoordinate2D destinationCoordinate, markCoordinate;
        destinationCoordinate.latitude = [[destCoordDict objectForKey:@"lat"] floatValue];
        destinationCoordinate.longitude = [[destCoordDict objectForKey:@"lon"] floatValue]; 
        
        NSNumber *markCount = [markCountList objectAtIndex:index];
        if( [markCount intValue] == 0 )
            markCoordinate = currentLocation.coordinate;
        else {
            markCoordinate.latitude = [[[coordinateList objectAtIndex:index] objectForKey:@"lat"] floatValue];
            markCoordinate.longitude = [[[coordinateList objectAtIndex:index] objectForKey:@"lon"] floatValue];
        }
        
        markDistance = [GreatCircleDistance distance:markCoordinate second:destinationCoordinate];
        currentDistance = [GreatCircleDistance distance:currentLocation.coordinate second:destinationCoordinate];
        delta = markDistance - currentDistance;
        if( delta > -0.005 )
        {
            gainedLost = @"gained";
            if( delta < 0.005 ) //like zero
                [subtitleColorList replaceObjectAtIndex:index withObject: [AppSettings subtitleColorStandard]];
            else
                [subtitleColorList replaceObjectAtIndex:index withObject: [AppSettings subtitleColorPositive]];
        } else {
            gainedLost = @"lost";
            [subtitleColorList replaceObjectAtIndex:index withObject: [AppSettings subtitleColorNegative]];
        }
        
        if( delta < 0 ) //abs
            delta = delta * -1;
        
        NSString *distanceText = [[NSString alloc] initWithFormat:@"%@ %1.2f miles", gainedLost, delta];
        [subtitleList addObject:distanceText];
        [distanceText release];
        
        index++;
    }
}

- (void)updateMovedDistance
{
    if( !coordinateList )
        return;
    if( subtitleList )
        [subtitleList release];
    subtitleList = [[NSMutableArray alloc] initWithCapacity:[coordinateList count]];
    
    if( subtitleColorList )
        [subtitleColorList release];
    subtitleColorList = [[NSMutableArray alloc] initWithCapacity:[coordinateList count]];
    
    for(int i = 0; i < [coordinateList count]; i++ )
        [subtitleColorList addObject:[AppSettings subtitleColorStandard]];
    
    int index = 0;
    float distance = 0;
    for(NSDictionary *coordDict in coordinateList)
    {
        NSNumber *markCount = [markCountList objectAtIndex:index];
        if( [markCount intValue] > 0 )
        {
            CLLocationCoordinate2D tagCoordinate;
            tagCoordinate.latitude = [[coordDict objectForKey:@"lat"] floatValue];
            tagCoordinate.longitude = [[coordDict objectForKey:@"lon"] floatValue]; 
            distance = [GreatCircleDistance distance:currentLocation.coordinate second:tagCoordinate];
        } else {
            distance = 0;
        }
        float payout = [[payoutList objectAtIndex:index] floatValue];
        int points = (int)(distance * payout);
        if( points > 0 )
            [subtitleColorList replaceObjectAtIndex:index withObject: [AppSettings subtitleColorPositive]];

        NSString *distanceText = [[NSString alloc] initWithFormat:@"moved %1.2f miles  (%d points )",distance, points];
        [subtitleList addObject:distanceText];
        [distanceText release];
        
        index++;
    }
}

#pragma mark RightBarButtons
- (UIBarButtonItem*)makeHelpButton
{
    return [[[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(showHelp:)] autorelease];
}

- (UIBarButtonItem*)makeToggleButton
{
    return [[[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleSubtitleText:)] autorelease];
}

# pragma mark other
- (void) startLocationManager
{
    if( !locManager ) 
    {
        locManager = [[CLLocationManager alloc] init];
        locManager.desiredAccuracy = [AppSettings desiredAccuracy];
        locManager.distanceFilter = [AppSettings distanceFilter];
        locManager.delegate = self;
    }
    [locManager startUpdatingLocation];    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self startLocationManager];
    
    
    if( skipAutoRefresh )
    {
        skipAutoRefresh = NO;
        return;
    }
    [self refreshData:nil]; 

}

- (void) viewDidDisappear:(BOOL)animated
{
    [locManager stopUpdatingLocation];
}

- (void) dropTagAtDepot:(NSDictionary*)data
{
    NSString *tagKey = [keyList objectAtIndex:selectedItemIndex];
    NSString *depotKey = [data objectForKey:@"depotKey"];
    
    [tagService dropAtDepot:tagKey depotKey:depotKey delegate:self didFinish:@selector(didDropAtDepot:) didFail:@selector(didFail:)];
    
    [keyList removeObjectAtIndex:selectedItemIndex];
    [list removeObjectAtIndex:selectedItemIndex];
    [self.tableView reloadData];
}

#pragma mark loading stuff

- (UISegmentedControl*) createSegment
{
    NSArray *items = [[NSArray alloc] initWithObjects:@"Tags",@"Depots",nil];
    UISegmentedControl *segment = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
    [items release];
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    segment.selectedSegmentIndex = 0;
    [segment addTarget:self action:@selector(changeViewMode:) forControlEvents:UIControlEventValueChanged];
    return segment;
}

- (void) changeViewMode:(id)sender
{
    viewMode = [sender selectedSegmentIndex];
    if( viewMode == kDepotView )
        self.navigationItem.rightBarButtonItem = [self makeHelpButton];
    else 
        self.navigationItem.rightBarButtonItem = [self makeToggleButton];
    
    [self refreshData:sender];
}

- (void)showHelp:(id)sender
{
    HelpViewController *helpController = [[HelpViewController alloc] initWithFile:@"depots"];
    [self presentModalViewController:helpController animated:YES];
    [helpController release]; 
}

#pragma mark JTServiceCalls

- (void) didGetDepots:(NSDictionary*)dict
{
    if( depotList ) {
        [depotList release];
        depotList = nil;
    }
    depotList = [[NSMutableArray alloc] initWithCapacity:0];
    
    if( depotKeyList) {
        [depotKeyList release];
        depotKeyList = nil;
    }
    depotKeyList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *depots = [dict objectForKey:@"depots"];
    for( NSDictionary *depot in depots )
    {
        NSString *number = [depot objectForKey:@"number"];
        NSString *depotName = [[NSString alloc] initWithFormat:@"Depot #%@",number];
        
        [depotList addObject:depotName];
        [depotName release];
        
        [depotKeyList addObject:[depot objectForKey:@"key"]];
    }
    if( [depotList count] == 0)
    {
        [depotList addObject:@"You dropped all your depots"];
    }
    [self.tableView reloadData];    
    self.navigationItem.leftBarButtonItem =  [ActivityButtonUtil createRefreshButton:self action:@selector(refreshData:)];
}

- (void) didGetInventories:(NSDictionary*)dict
{
    if( list)
        [list release];
    list = [[NSMutableArray alloc] initWithCapacity:0];
    
    if( keyList )
        [keyList release];
    keyList = [[NSMutableArray alloc] initWithCapacity:0];

    if( subtitleList )
        [subtitleList release];
    subtitleList = [[NSMutableArray alloc] initWithCapacity:0];
    
    if( coordinateList )
        [coordinateList release];
    coordinateList = [[NSMutableArray alloc] initWithCapacity:0];
    
    if( markCountList )
        [markCountList release];
    markCountList = [[NSMutableArray alloc] initWithCapacity:0];
    
    if( destinationCoordinateList )
        [destinationCoordinateList release];
    destinationCoordinateList = [[NSMutableArray alloc] initWithCapacity:0];
    
    if( payoutList )
        [payoutList release];
    payoutList = [[NSMutableArray alloc] initWithCapacity:0];
    
    if( currentAccuracyList )
        [currentAccuracyList release];
    currentAccuracyList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *inventoryList = [dict objectForKey:@"inventories"];
    for(NSDictionary *inventory in inventoryList)
    {
        [list addObject:[inventory objectForKey:@"tagName"]];
        [keyList addObject:[inventory objectForKey:@"tag"]];
        [coordinateList addObject:[inventory objectForKey:@"coordinate"]];
        [subtitleList addObject:@""];
        NSNumber *markCount = [[NSNumber alloc] initWithInt:[[inventory objectForKey:@"markCount"] intValue]];
        [markCountList addObject:markCount];
        [markCount release];
        
        [destinationCoordinateList addObject:[inventory objectForKey:@"destinationCoordinate"]];
        [payoutList addObject:[inventory objectForKey:@"payout"]];
        [currentAccuracyList addObject:[inventory objectForKey:@"destinationAccuracy"]];
    }
    
    [self updateSubtitleMode];
    hasTags = YES;
    
    [self.tableView reloadData];
    
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createRefreshButton:self action:@selector(refreshData:)];
}

- (void) didDropTag:(NSDictionary*)data
{
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createRefreshButton:self action:@selector(refreshData:)];
}

- (void) didDropDepot:(NSDictionary*)dict
{
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createRefreshButton:self action:@selector(refreshData:)];
}

-(void) didDropAtDepot:(NSDictionary*)dict
{

}

- (void) didFail:(id)sender
{   
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createRefreshButton:self action:@selector(refreshData:)];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Operation Failed" message:@"" delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{

    if( viewMode == kTagView )
        return [list count];
    else  if( viewMode == kDepotView )
        return [depotList count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *tagIdentifier = @"tagCell";
    static NSString *depotIdentifier = @"depotCell";
    UITableViewCell *cell;   
    
    if( viewMode == kTagView )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:tagIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tagIdentifier] autorelease];
        }
        
        cell.textLabel.text = [list objectAtIndex:indexPath.row];
        if( hasLocation && hasTags) {
            cell.detailTextLabel.text = [subtitleList objectAtIndex:indexPath.row];
            cell.detailTextLabel.textColor = [subtitleColorList objectAtIndex:indexPath.row];
            if( [[showImageList objectAtIndex:indexPath.row] boolValue] )
                cell.imageView.image = destinationImage;
            else 
                cell.imageView.image = nil;

        } 

    } 
    if( viewMode == kDepotView)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:depotIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:depotIdentifier] autorelease];
        }
        
        cell.textLabel.text = [depotList objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"";
    }

    cell.accessoryType = [self accessoryTypeForRowWithIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if( indexPath.section == 0 )
    {
        selectedItemIndex = indexPath.row;
        
        if( viewMode == kTagView )
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Drop Tag" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Drop Here",@"Drop at Depot", @"Drop + Quick Pickup", nil];
            sheet.destructiveButtonIndex = 0;
            [sheet showInView:self.parentViewController.tabBarController.view];
            [sheet release];
        } else if( viewMode == kDepotView ) {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Drop Depot?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Drop Here",nil];
            sheet.destructiveButtonIndex = 0;
            [sheet showInView:self.parentViewController.tabBarController.view];
            [sheet release];
        }
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (UITableViewCellAccessoryType) accessoryTypeForRowWithIndexPath:(NSIndexPath*)indexPath
{
    return viewMode == kTagView ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;
}

- (void) tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    DropTagDetailsTableViewController *controller = [[DropTagDetailsTableViewController alloc] init];
    controller.tagKey = [keyList objectAtIndex:indexPath.row];
    controller.currentLocation = locManager.location.coordinate;
    controller.hasLocation = hasLocation;
    
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

# pragma mark actionSheet
- (void) actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(viewMode ==  kTagView) {
        if( buttonIndex == 0) 
        {
            [self takePicture];
        } 
        else if( buttonIndex == 1 ) 
        {
            DepotTableViewController *controller = [[DepotTableViewController alloc] initWithTagKey:[keyList objectAtIndex:selectedItemIndex] target:self action:@selector(dropTagAtDepot:)];
            controller.hidesBottomBarWhenPushed = NO;
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        } 
        else if( buttonIndex == 2 ) 
        {
            dropAndPickup = YES;
            [self takePicture];
        }
    }
    if(viewMode == kDepotView) {
        if( buttonIndex == 0 ) {
            [self takePicture];
        }
    }
}

#pragma mark imagePickerController
- (void) takePicture {
    
    //negative horizontalAccuracy indicates invalid lat/lon
    if( !currentLocation || ( currentLocation && currentLocation.horizontalAccuracy < 0 ) ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"I don't have your current location yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    if( currentLocation.horizontalAccuracy > [AppSettings desiredGpsAccuracyInMeters] ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"GPS accuracy is not at least 100 yards.  Try again in a minute or two." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;        
    }
    
    if( [[UIDevice currentDevice].uniqueIdentifier compare:@"BCDB12A8-0EA2-54AC-BCB2-B48E7165EB44"] == NSOrderedSame )
    {
        FakeImagePickerViewController *fakePicker = [[FakeImagePickerViewController alloc] initWithDelegate:self selector:@selector(didPickFakeImage:)];
        [self presentModalViewController:fakePicker animated:YES];
        [fakePicker release];
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
}

- (void)didPickFakeImage:(id)nothing
{
    UIImage *image = [UIImage imageNamed:@"ExamplePhotoHorizontal.jpg"];    
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:image, UIImagePickerControllerOriginalImage,nil];
    [self imagePickerController:nil didFinishPickingMediaWithInfo:info];    
    [info release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    if( !currentLocation )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"I don't have your current location yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    if( currentLocation.horizontalAccuracy > [AppSettings desiredGpsAccuracyInMeters] )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"GPS accuracy is not at least 100 yards.  Try again in a minute or two." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;        
    }
    
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createActivityIndicatorButton];
    skipAutoRefresh = YES;    
    if( viewMode == kTagView )
    {
        if( selectedKey ) {
            [selectedKey release];
            selectedKey = nil;
        }
        selectedKey = [[keyList objectAtIndex:selectedItemIndex] retain];
        
        if( !dropAndPickup )
        {
            [list removeObjectAtIndex:selectedItemIndex];
            [keyList removeObjectAtIndex:selectedItemIndex];
            
            [subtitleList removeObjectAtIndex:selectedItemIndex];
            [coordinateList removeObjectAtIndex:selectedItemIndex];
            [markCountList removeObjectAtIndex:selectedItemIndex];
            [destinationCoordinateList removeObjectAtIndex:selectedItemIndex];
            [subtitleColorList removeObjectAtIndex:selectedItemIndex];
            [showImageList removeObjectAtIndex:selectedItemIndex];
        }
    } else {
        if( selectedKey )
            [selectedKey release];
        selectedKey = [[depotKeyList objectAtIndex:selectedItemIndex] retain];
        [depotList removeObjectAtIndex:selectedItemIndex];
        [depotKeyList removeObjectAtIndex:selectedItemIndex];
    }
    [self.tableView reloadData];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    //non-asynchronous way
    UIImage *resizedImage = [ImageResize resizeImage:image widthConstraint:[AppSettings imageHeight] heightConstraint:[AppSettings imageHeight]];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, [AppSettings imageQuality]);
    [self uploadImage:imageData];
    
    //synchronized way
    //ImageResizeOperation *operation = [[ImageResizeOperation alloc] initWithImage:image delegate:self didFinish:@selector(uploadImage:)];
    //[queue addOperation:operation];
    //[operation release];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) uploadImage:(NSData*)imageData
{
    if( viewMode == kTagView ) 
    {
        NSString *tagKey = selectedKey;
        if( dropAndPickup )
        {
            [tagService dropAndPickup:tagKey imageData:imageData lat:currentLocation.coordinate.latitude lon:currentLocation.coordinate.longitude delegate:self didFinish:@selector(didDropTag:) didFail:@selector(didFail:)];
            dropAndPickup = NO; //important!!! don't want next tag to do this
        } else {
            [tagService drop:tagKey imageData:imageData lat:currentLocation.coordinate.latitude lon:currentLocation.coordinate.longitude delegate:self didFinish:@selector(didDropTag:) didFail:@selector(didFail:)];        
        }
    } 
    else if( viewMode == kDepotView ) 
    {
        NSString *depotKey = selectedKey;
        [depotService drop:depotKey imageData:imageData lat:currentLocation.coordinate.latitude lon:currentLocation.coordinate.longitude delegate:self didFinish:@selector(didDropDepot:) didFail:@selector(didFail:)];
    }
}

#pragma mark Refresh
- (void) refreshData:(id)sender
{
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createActivityIndicatorButton];
    switch (viewMode) {
        case kTagView:
            [self refreshTags:sender];
            break;
        case kDepotView:
            [self refreshDepots:sender];
            break;
        default:
            break;
    }
}

- (void) refreshDepots:(id)sender
{
    [depotService getAllByStatus:TRUE delegate:self didFinish:@selector(didGetDepots:) didFail:@selector(didFail:)];            
}

- (void) refreshTags:(id)sender
{
    [inventoryService get:self didFinish:@selector(didGetInventories:) didFail:@selector(didFail:)];
}

#pragma mark CLLocationManagerDelegate
- (void) locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation
{
    [currentLocation release];
    currentLocation = [newLocation retain];
    hasLocation = YES;
    if( viewMode == kTagView )
        [self updateSubtitleMode];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    hasLocation = NO;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Could not get current location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [manager stopUpdatingLocation];
}

#pragma mark -

- (void)dealloc {
    [list release];
    [keyList release];
    
    [depotList release];
    [depotKeyList release];
    
    [selectedKey release];
    
    [locManager release];
    [currentLocation release];
    
    [inventoryService cancelReadRequests];
    [inventoryService release];
    
    [depotService cancelReadRequests];
    [depotService release];
    
    [tagService cancelReadRequests];
    [tagService release];
    
    [queue cancelAllOperations];
    [queue release];
    
    [subtitleList release];
    [coordinateList release];
    [markCountList release];
    [destinationCoordinateList release];
    [subtitleColorList release];
    [payoutList release];
    [currentAccuracyList release];

    [dropSettings release];
    
    [destinationImage release];
    [super dealloc];
}


@end

