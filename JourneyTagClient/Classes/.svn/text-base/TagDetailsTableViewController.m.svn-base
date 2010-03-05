//
//  TagDetailsTableViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagDetailsTableViewController.h"
#import "TagHistoryViewController.h"
#import "GreatCircleDistance.h"
#import "DestinationLocationViewController2.h"
#import "TraveledMapViewController.h"
#import "TableCellUtil.h"
#import "PlaceMarkFormatter.h"
#import "AppSettings.h"
#import "DateTimeUtil.h"

@implementation TagDetailsTableViewController
@synthesize tagKey, withinPickupRange, currentLocation, hasLocation;
@synthesize pickupDelegate, didPickupTagSelector;
@synthesize tableView=myTableView;

#define kTableViewTag 5

- (id)init
{
    self = [super init];
    
    self.title = @"Tag Details";
    
    youOwn = NO;
    tagService = [[JTTagService alloc] init];
    
    [self loadLabels];
    
    locManager = [[CLLocationManager alloc] init];
    locManager.distanceFilter = [AppSettings distanceFilter];
    locManager.desiredAccuracy = [AppSettings desiredAccuracy];
    locManager.delegate = self;
    
    return self;
}

- (void)loadView
{
    [super loadView];//remember, this must go first!

    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = view;
    [view release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    tableView.tag = kTableViewTag;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    [tableView release];
}

- (void)viewDidLoad 
{
    [self refreshData]; 
    [super viewDidLoad];
}

- (void)viewDidUnload
{    
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    
    self.view = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    if( locManager )
        [locManager startUpdatingLocation];
    
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if( geoCoder && geoCoder.querying )
        [geoCoder cancel];

    [locManager stopUpdatingLocation];
    
    [super viewDidDisappear:animated];
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation.coordinate;
    hasLocation = YES;
    
    [self updateLocationValues];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    hasLocation = NO;
}

- (void)updateLocationValues
{
    if( locSectionValues && [locSectionValues count] > 0 )
    {
        shouldUpdateLocationValues = NO;
        NSString *distanceString;
        if( isNewTag ) 
        {
            distanceString = [[NSString alloc] initWithFormat:@"n/a"];
        } else {
            int distanceInMeters = [GreatCircleDistance distanceInMeters:currentLocation second:tagLocation];
            float distanceInMiles = [GreatCircleDistance metersToMiles:distanceInMeters];
            if( distanceInMiles < 0.25 ) {
                distanceString = [[NSString alloc] initWithFormat:@"%d yards", distanceInMeters];                
            } else {
                distanceString = [[NSString alloc] initWithFormat:@"%1.2f miles", distanceInMiles];
            }
        }
        
        [locSectionValues replaceObjectAtIndex:0 withObject:distanceString];
        [distanceString release];
    } else {
        shouldUpdateLocationValues = YES;
    }
    
    if( infoSectionValues && [infoSectionValues count] > 0 )
    {
        //purposely don't set shouldUpdateLocationValues to NO
        NSString *distanceText;
        if( hasArrivedAtFinalDestination )
        {
            distanceText = @"n/a";
        } 
        else 
        {
            CLLocationCoordinate2D measureCoordinate;
            if( isNewTag || !isDropped )
                measureCoordinate = currentLocation;
            else
                measureCoordinate = tagLocation;
                
            double bearingDegrees = [GreatCircleDistance getBearingFromCoordinate:measureCoordinate toCoordinate:destinationCoordinate];
            NSString *bearingName = [GreatCircleDistance getBearingNameFromDegrees:bearingDegrees];
            int distanceFromDestinationInMeters = [GreatCircleDistance distanceInMeters:measureCoordinate second:destinationCoordinate];
            float distanceInMiles = [GreatCircleDistance metersToMiles:distanceFromDestinationInMeters];

            if( distanceInMiles < 0.25 )
                distanceText = [[NSString alloc] initWithFormat:@"%d yards to the %@", distanceFromDestinationInMeters, bearingName];        
            else
                distanceText = [[NSString alloc] initWithFormat:@"%1.2f miles to the %@", distanceInMiles, bearingName];

            [distanceText autorelease];
        }
        
        [infoSectionValues replaceObjectAtIndex:1 withObject:distanceText];
    } else {
        shouldUpdateLocationValues = YES;
    }

    [self.tableView reloadData];
    
    [self reverseLookupTagLocation];
}

- (void) refreshData
{
    if( isUpdatingTable )
        return;
    
    isUpdatingTable = YES;
    [tagService get:self.tagKey delegate:self didFinish:@selector(didLoadTag:) didFail:@selector(didFail:)]; 
}

- (void) loadLabels
{
    sectionTitles = [[NSMutableArray alloc] initWithObjects:@"Information", @"History", @"Current Location", @"Dates", nil];
    infoSectionLabels = [[NSArray alloc] initWithObjects:@"Name:",@"Destination:",@"Status:",@"Owner:",nil];
    travelSectionLabels = [[NSArray alloc] initWithObjects:@"Photos:",@"Traveled:",nil];
    locSectionLabels = [[NSArray alloc] initWithObjects:@"Distance from you:", @"",nil];
    dateSectionLabels = [[NSArray alloc] initWithObjects:@"Created:", @"Activity:", nil];
}

#pragma mark JTService
- (void) didLoadTag:(NSDictionary*)dict
{   
    NSString *statusValue = [dict objectForKey:@"status"];
    isNewTag = [statusValue caseInsensitiveCompare:@"new"] == NSOrderedSame;
    
    tagLevel = [[dict objectForKey:@"level"] intValue];
    
    if( !isNewTag)
    {
        tagLocation.latitude = [[[dict objectForKey:@"currentCoordinate"] objectForKey:@"lat"] floatValue];
        tagLocation.longitude = [[[dict objectForKey:@"currentCoordinate"] objectForKey:@"lon"] floatValue];
    }
    
    NSString *distanceString;
    NSString *distancePlace = isNewTag ? @"not dropped" : @"Loading...";
    if( isNewTag || !hasLocation ) 
    {
        distanceString = @"n/a";
    } else {
        float distance = [GreatCircleDistance distance:currentLocation second:tagLocation];
        distanceString = [[NSString alloc] initWithFormat:@"%1.2f miles",distance];
    }
    
    locSectionValues = [[NSMutableArray alloc] initWithObjects: 
                        distanceString,
                        distancePlace,
                        nil];
    [distanceString release];
    
    destinationCoordinate.latitude = [[[dict objectForKey:@"currentDestinationCoordinate"] objectForKey:@"lat"] doubleValue];
    destinationCoordinate.longitude = [[[dict objectForKey:@"currentDestinationCoordinate"] objectForKey:@"lon"] doubleValue];
    
    NSString *bearingName;
    NSString *status;
    if( isNewTag )
    {
        status = @"new";
    } else {
        if( [statusValue caseInsensitiveCompare:@"ended"] == NSOrderedSame )
        {
            status = @"Finished";
            hasArrivedAtFinalDestination = YES;
            bearingName = @"Arrived";
        } else if([(NSString*)[dict objectForKey:@"pickedUp"] compare:@"True"] == NSOrderedSame  ) {
            [sectionTitles replaceObjectAtIndex:2 withObject:@"Last Pickup Location"];
            status = @"in transit";
        } else {
            status = @"dropped";
        }
    }
    
    hasReachedDestination = [(NSString*)[dict objectForKey:@"hasReachedDestination"] compare:@"True"] == NSOrderedSame;
    isDropped = [(NSString*)[dict objectForKey:@"pickedUp"] compare:@"False"] == NSOrderedSame;
    
    int distanceFromDestinationInMeters = 0;
    NSString *distanceText;
    if( hasArrivedAtFinalDestination )
    {
        distanceText = @"n/a";
    } 
    else
    {
        if( isNewTag )
        {
            if( hasLocation )
            {
                double bearingDegrees = [GreatCircleDistance getBearingFromCoordinate:currentLocation toCoordinate:destinationCoordinate];
                bearingName = [GreatCircleDistance getBearingNameFromDegrees:(double)bearingDegrees];
                distanceFromDestinationInMeters = [GreatCircleDistance distanceInMeters:currentLocation second:destinationCoordinate];
            } else {
                bearingName = @"?"; 
            }
        } else {
            double bearingDegrees = [GreatCircleDistance getBearingFromCoordinate:tagLocation toCoordinate:destinationCoordinate];
            bearingName = [GreatCircleDistance getBearingNameFromDegrees:(double)bearingDegrees];
            distanceFromDestinationInMeters = [GreatCircleDistance distanceInMeters:tagLocation second:destinationCoordinate];
        }
    
    float distanceInMiles = [GreatCircleDistance metersToMiles:distanceFromDestinationInMeters];

    if( distanceInMiles < 0.25 )
        distanceText = [[NSString alloc] initWithFormat:@"%d yards to the %@", distanceFromDestinationInMeters, bearingName];        
    else
        distanceText = [[NSString alloc] initWithFormat:@"%1.2f miles to the %@", distanceInMiles, bearingName];

    }
    infoSectionValues = [[NSMutableArray alloc] initWithObjects:
                         [dict objectForKey:@"name"],
                         distanceText,
                         status,
                         [dict objectForKey:@"account_username"],
                         nil];
    [distanceText release];
    
    NSString *distanceTraveled = [[NSString alloc] initWithFormat:@"%@ miles", [dict objectForKey:@"distanceTraveled"]];
    travelSectionValues = [[NSArray alloc] initWithObjects:
                       [dict objectForKey:@"markCount"],
                       distanceTraveled,
                       nil];
    [distanceTraveled release];
    
    youOwn = [(NSString*)[dict objectForKey:@"youOwn"] compare:@"True"] == NSOrderedSame;
    
    dateSectionValues = [[NSArray alloc] initWithObjects:
        [DateTimeUtil localDateStringFromUtcString:[dict objectForKey:@"dateCreated"]],
        [DateTimeUtil localDateStringFromUtcString:[dict objectForKey:@"lastUpdated"]],
                         nil];
    
    
    isUpdatingTable = NO;
    
    currentAccuracy = [[dict objectForKey:@"destinationAccuracy"] intValue];
    if( shouldUpdateLocationValues )
        [self updateLocationValues];
    else
        [self.tableView reloadData];
}

#pragma mark MKReverseGeocoderDelegate
- (void)reverseLookupTagLocation
{
    if( geoCoder )
    {
        [geoCoder cancel];
        [geoCoder release];
        geoCoder = nil;
    }
    geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:tagLocation];
    geoCoder.delegate = self;
    [geoCoder start];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    [locSectionValues replaceObjectAtIndex:1 withObject:[PlaceMarkFormatter standardFormat:placemark]];
    [self.tableView reloadData];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSString *coord = [[NSString alloc] initWithFormat:@"%1.4f, %1.4f", tagLocation.latitude, tagLocation.longitude];
    [locSectionValues replaceObjectAtIndex:1 withObject:coord];
    [coord release];
    [self.tableView reloadData];
}

- (void) didFail:(id)sender
{
}

#pragma mark ActionSheet
- (void) confirmTagPickup
{
    UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Confirm Pickup",@"Cancel",nil];
    confirm.destructiveButtonIndex = 0;
    confirm.actionSheetStyle = UIActionSheetStyleDefault;
    [confirm showInView:self.view];
    [confirm release];
}


- (void) actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if( buttonIndex == 0 )
        {
            [self pickupTag];     
        }
}

#pragma mark JTService
- (void) pickupTag
{
    [tagService pickup:self.tagKey delegate:self didFinish:@selector(didPickupTag:) didFail:@selector(didFail:)]; 
}

- (void) didPickupTag:(NSDictionary*)dict
{
    if( [(NSString*)[dict objectForKey:@"tagKey"] compare:@"False"] == NSOrderedSame )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too slow" message:@"Another player picked up this tag before you could." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release]; 
    } 

    //continue to remove the tag from the map
    if(self.didPickupTagSelector != nil && self.pickupDelegate != nil && [self.pickupDelegate respondsToSelector:self.didPickupTagSelector] )
    {
        [self.pickupDelegate performSelectorOnMainThread:self.didPickupTagSelector withObject:self.tagKey waitUntilDone:[NSThread isMainThread]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [infoSectionLabels count];
            break;
        case 1:
            return [travelSectionLabels count];
            break;
        case 2:
            return [locSectionLabels count];
            break;
        case 3:
            return [dateSectionLabels count];
            break;
        default:
            return 0; //never
            break;
    }
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitles objectAtIndex:section];
}

- (UITableViewCellAccessoryType) accessoryTypeForRowWithIndexPath:(NSIndexPath*)indexPath
{
    if( !hasArrivedAtFinalDestination && [indexPath section] == 0 && [indexPath row] == 1)
    {
        return UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if( [indexPath section] == 1 && ( indexPath.row == 0 || indexPath.row == 1 ) )
    {
        return UITableViewCellAccessoryDisclosureIndicator;
    }
    return UITableViewCellAccessoryNone;
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(!hasArrivedAtFinalDestination && indexPath.section == 0 && indexPath.row == 1 )
    {
        //yes, I know how messy this looks!
        DestinationLocationViewController2 *controller = [[DestinationLocationViewController2 alloc] init];
        controller.destinationLocation = destinationCoordinate;
        controller.tagLocation = tagLocation;
        controller.isNewTag = isNewTag;
        controller.tagKey = self.tagKey;
        controller.hasReachedDestination = hasReachedDestination;
        controller.isDropped = isDropped;
        controller.withinPickupRange = withinPickupRange;
        controller.tagLevel = tagLevel;
        controller.currentAccuracy = currentAccuracy;
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
    } else if( [indexPath section] == 1 && indexPath.row == 0 )
    {
        TagHistoryViewController *controller = [[TagHistoryViewController alloc] init];
        controller.tagKey = self.tagKey;
        controller.canVote = youOwn;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];       
        [controller release];
    } else if ( indexPath.section == 1 && indexPath.row == 1 )
    {
        TraveledMapViewController *childController = [[TraveledMapViewController alloc] initWithTagKey:tagKey];
        [self.navigationController pushViewController:childController animated:YES];
        [childController release];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    if( isUpdatingTable )
    {
        cell.textLabel.text =@"";
        return cell;
    }
    
    if( [indexPath section] == 0 ) {
        [TableCellUtil setupCustomCell:cell
                    labelText:[infoSectionLabels objectAtIndex:[indexPath row]] 
                    valueText:[infoSectionValues objectAtIndex:[indexPath row]]];
    } else if( [indexPath section] == 1 ) {
        [TableCellUtil setupCustomCell:cell
        labelText:[travelSectionLabels objectAtIndex:[indexPath row]] 
        valueText:[travelSectionValues objectAtIndex:[indexPath row]]];

    } else if( [indexPath section] == 2 ) {
        if( [indexPath row] == 0 ) {
            [TableCellUtil setupMediumLabeledCustomCell:cell
                                    labelText:[locSectionLabels objectAtIndex:[indexPath row]] 
                                    valueText:[locSectionValues objectAtIndex:[indexPath row]]];    
        } else {
            cell.textLabel.text = [locSectionValues objectAtIndex:indexPath.row];
            cell.textLabel.font = [TableCellUtil valueFont];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.minimumFontSize = 9;
        }
    } else if (indexPath.section == 3 )
    {
        [TableCellUtil setupCustomCell:cell
                    labelText:[dateSectionLabels objectAtIndex:indexPath.row] 
                    valueText:[dateSectionValues objectAtIndex:indexPath.row]];
        
    }
    
    cell.accessoryType = [self accessoryTypeForRowWithIndexPath:indexPath];

    return cell;
}

- (void)dealloc {
    //self.tagKey = nil;
    self.pickupDelegate = nil;
    
    [list release];
    [labels release];
    
    [infoSectionValues release];
    [infoSectionLabels release];
    
    [travelSectionValues release];
    [travelSectionLabels release];
    
    [locSectionValues release];
    [locSectionLabels release];
    
    [dateSectionLabels release];
    [dateSectionValues release];
    
    [tagService cancelReadRequests];
    [tagService release];

    [locManager stopUpdatingLocation];
    [locManager release];
        
    [sectionTitles release];
        
    [geoCoder cancel];
    [geoCoder release];
    
    self.tableView = nil;
    
    [super dealloc];
}


@end

