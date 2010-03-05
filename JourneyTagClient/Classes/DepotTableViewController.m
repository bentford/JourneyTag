//
//  DepotTableViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 5/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DepotTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@implementation DepotTableViewController

- (id)initWithTagKey:(NSString*)tagKey target:(id)target action:(SEL)didChooseDepot
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    myTagKey = [tagKey retain];
    myTarget = [target retain];
    myDidChooseDepotSelector = didChooseDepot;
    
    list = [[NSMutableArray alloc] initWithObjects:@"Loading...",nil];
    locationNoteList = [[NSMutableArray alloc] initWithObjects:@"",nil];
    statusLabels = [[NSArray alloc] initWithObjects:@"OK", @"Blocked.  (allowed one time only)",nil];
    
    depotService = [[JTDepotService alloc] init];    
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    isLoading = YES;
    [depotService getAllAsTargetForTag:myTagKey delegate:self didFinish:@selector(didGetDepots:) didFail:@selector(didFail:)];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if( geocoder && geocoder.querying )
        [geocoder cancel];
    [depotService cancelReadRequests];
    
    [super viewDidDisappear:animated];
}

- (void) didGetDepots:(NSDictionary*)dict
{
    if( list ) {
        [list release];
        list = nil;
    }
    list = [[NSMutableArray alloc] initWithCapacity:0];
    
    if( keyList ) {
        [keyList release];
        keyList = nil;
    }
    keyList = [[NSMutableArray alloc] initWithCapacity:0];
  
    if( statusList ) {
        [statusList release];
        statusList = nil;
    }
    statusList = [[NSMutableArray alloc] initWithCapacity:0];
    
    if( locationNoteList ) {
        [locationNoteList release];
        locationNoteList = nil;
    }
    locationNoteList = [[NSMutableArray alloc] initWithCapacity:0];

    if( depotList )  {
        [depotList release];
        depotList = nil;
    }
    depotList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *depots = [dict objectForKey:@"depots"];
    for( NSDictionary *depot in depots )
    {
        NSString *depotName = [[NSString alloc] initWithFormat:@"Depot #%@",[depot objectForKey:@"number"]];
        [list addObject:depotName];
        [depotName release];
        
        [depotList addObject:depot];
        
        NSString *depotKey = [depot objectForKey:@"key"];
        [keyList addObject:depotKey];
        
        NSString *status = [depot objectForKey:@"tagCanUse"];
        [statusList addObject:status];
        [locationNoteList addObject:@"?"];
    }
    isLoading = NO;
    [self.tableView reloadData];
    [self loadLocationNote];
}

- (void) didFail:(id)sender
{
    
}

- (void) loadLocationNote
{
    if( currentLocationNoteIndex >= [locationNoteList count] )
    {
        return;
    }
    NSDictionary *depot = [depotList objectAtIndex:currentLocationNoteIndex] ;
    
    CLLocationCoordinate2D coord;
    coord.latitude = [[[depot objectForKey:@"coordinate"] objectForKey:@"lat"] floatValue];
    coord.longitude = [[[depot objectForKey:@"coordinate"] objectForKey:@"lon"] floatValue];
    
    if( geocoder != nil )
    {
        [geocoder release];
        geocoder = nil;
    }
    geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coord];
    geocoder.delegate = self;
    [geocoder start];
}

#pragma mark MKReverseGeocoderDelegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    NSString *first = [placemark.locality length] != 0 ? placemark.locality : placemark.subAdministrativeArea; 
    first = [first length] != 0 ? first : placemark.postalCode;
    NSString *info = [[NSString alloc] initWithFormat:@"%@, %@, %@",first, placemark.administrativeArea, placemark.country];
    
    [locationNoteList replaceObjectAtIndex:currentLocationNoteIndex withObject:info];
    [info release];
    [self.tableView reloadData];
    
    currentLocationNoteIndex++;
    [self loadLocationNote];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    currentLocationNoteIndex++;
    [self loadLocationNote];
}
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"depotRow";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *mainLabel = [[NSString alloc] initWithFormat:@"%@ - %@",[list objectAtIndex:indexPath.row], [locationNoteList objectAtIndex:indexPath.row]];
    cell.textLabel.text = mainLabel;
    [mainLabel release];
    
    if( isLoading )
    {
        cell.detailTextLabel.text = @"";
    }
    else 
    {
        NSString *status = [statusList objectAtIndex:indexPath.row];
        int statusLabelIndex = 0;
        if( [status isEqualToString:@"False"] )
        {
            statusLabelIndex = 1;
        }
        cell.detailTextLabel.text = [statusLabels objectAtIndex:statusLabelIndex];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if( [[statusList objectAtIndex:indexPath.row] isEqualToString:@"False"] )
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    selectedDepot = indexPath.row;
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Drop Now" otherButtonTitles:nil];
    [action showInView:self.view];
    [action release];
}

- (void) actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 )
    {
        NSString *depotKey = [keyList objectAtIndex:selectedDepot];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:depotKey,@"depotKey",nil];
        
        if( myTarget && myDidChooseDepotSelector && [myTarget respondsToSelector:myDidChooseDepotSelector] )
            [myTarget performSelectorOnMainThread:myDidChooseDepotSelector withObject:data waitUntilDone:[NSThread isMainThread]];

        [data release];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc 
{    
    [list release];
    [keyList release];
    [statusList release];
    [locationNoteList release];
    [depotList release];
    
    [geocoder cancel];
    [geocoder release];
    [depotService release];
    
    [myTagKey release];
    [myTarget release];
    [statusLabels release];

    [super dealloc];
}


@end

