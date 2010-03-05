//
//  DepotIndexTableViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DepotIndexTableViewController.h"


@implementation DepotIndexTableViewController
- (id)initWithDelegate:(id)delegate didSelectDepot:(SEL)didSelectDepotSelector
{
    self = [super init];
    
    myDelegate = [delegate retain];
    myDidSelectDepotSelector = didSelectDepotSelector;
    depotService = [[JTDepotService alloc] init];
    
    return self;
}

- (void)viewDidLoad 
{
    list = [[NSArray alloc] initWithObjects:@"Loading...", nil];
    locationNoteList = [[NSMutableArray alloc] initWithObjects:@"",nil];

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [list release];
    [locationNoteList release];
    
    list = nil;
    locationNoteList = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [depotService getAllByStatus:NO delegate:self didFinish:@selector(didGetDepots:) didFail:@selector(didFail:)];    
    [super viewDidAppear:animated];
}

#pragma mark service calls
- (void) didGetDepots:(NSDictionary*)dict
{
    if( list )
        [list release];
    if( depotList )
        [depotList release];
    if( locationNoteList )
        [locationNoteList release];
    
    list = [[NSMutableArray alloc] initWithCapacity:0];    
    depotList = [[NSMutableArray alloc] initWithCapacity:0];
    locationNoteList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *depots = [dict objectForKey:@"depots"];
    for( NSDictionary *depot in depots )
    {
        [depotList addObject:depot];
        
        NSString *depotName = [[NSString alloc] initWithFormat:@"Depot #%@",[depot objectForKey:@"number"]];
        [list addObject:depotName];
        [depotName release];
        
        [locationNoteList addObject:@"?"];
    }
    BOOL shouldLoadLocationNote = YES;
    if( [list count] == 0)
    {
        [list addObject:@"You have no deployed depots"];
        [locationNoteList addObject:@""];
        [depotList addObject:@""];
        shouldLoadLocationNote = NO;
    } 
    [self.tableView reloadData];    
    if( shouldLoadLocationNote )
        [self loadLocationNote];
    
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
    
    if( geocoder )
    {
        [geocoder cancel];
        [geocoder release];
        geocoder = nil;
    }
    geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coord];
    geocoder.delegate = self;
    [geocoder start];
}

- (void) didFail:(id)sender
{
    
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
    }
    
    NSString *note; 
    if( locationNoteList && [locationNoteList count] > 0 )
        note = [locationNoteList objectAtIndex:indexPath.row];
    else
        note = @"?";
    
    NSString *mainLabel = [[NSString alloc] initWithFormat:@"%@ - %@",[list objectAtIndex:indexPath.row], note];
    cell.textLabel.text = mainLabel;
    [mainLabel release];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSDictionary *depot = [depotList objectAtIndex:indexPath.row];

    if (myDidSelectDepotSelector && myDelegate && [myDelegate respondsToSelector:myDidSelectDepotSelector]) 
    {
        [myDelegate performSelectorOnMainThread:myDidSelectDepotSelector withObject:depot waitUntilDone:[NSThread isMainThread]];
    }
}
#pragma mark MKReverseGeocoderDelegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    NSString *first = [placemark.locality length] != 0 ? placemark.locality : placemark.subAdministrativeArea; 
    first = [first length] > 0 ? first : placemark.postalCode;
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

- (void)dealloc {
    [list release];
    [depotList release];
    [locationNoteList release];
    
    [depotService cancelReadRequests];
    [depotService release];
    
    [geocoder cancel];
    [geocoder release];

    [myDelegate release];
    
    [super dealloc];
}
@end

