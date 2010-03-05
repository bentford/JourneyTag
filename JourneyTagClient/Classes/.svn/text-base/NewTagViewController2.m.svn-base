//
//  NewTagController2.m
//  JourneyTag
//
//  Created by Ben Ford on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NewTagViewController2.h"
#import "NewTagDetailViewController.h"
#import "ChooseDestinationViewController.h"
#import "TableCellUtil.h"
#import "HelpViewController.h"
#import "JTFormListViewController.h"
#import "GreatCircleDistance.h"
#import "DeleteTagViewController.h"
#import "PlaceMarkFormatter.h"

@implementation NewTagViewController2

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];

    self.title = @"Create Tag";
    [self setup];
    editExistingTag = NO;
    didDeleteTag = NO;
    
    return self;
}

- (id)initWithTagKey:(NSString*)tagKey name:(NSString*)name destinationCoordinate:(CLLocationCoordinate2D)_destinationCoordinate accuracyInMeters:(int)accuracyInMeters delegate:(id)delegate didFinish:(SEL)didFinish
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    self.title = @"Edit Tag";
    [self setup];
    
    editExistingTag = YES;    
    didDeleteTag = NO;
    
    existingTagKey = tagKey;
    destinationCoordinate = _destinationCoordinate;
    [self setDestinationCoordinateWorker:destinationCoordinate.latitude lon:destinationCoordinate.longitude];
    
    [sectionLabels replaceObjectAtIndex:0 withObject:name];

    if( accuracyInMeters == 10 )
        accuracyInMeters = 100;
    
    NSNumber *accuracyNumber = [NSNumber numberWithInt:accuracyInMeters];

    //prevents a crash with server code change
    int indexOfAccuracyInMeters;
    if( [accuracyValues containsObject:accuracyNumber] )
        indexOfAccuracyInMeters = [accuracyValues indexOfObject:accuracyNumber];
    else 
        indexOfAccuracyInMeters = [GreatCircleDistance milesToMeters:5];
    
    NSString *accuracyText = [accuracyList objectAtIndex:indexOfAccuracyInMeters];
    [sectionLabels replaceObjectAtIndex:2 withObject:accuracyText];
    
    [sectionLabels replaceObjectAtIndex:3 withObject:@"Save Changes"];
    
    myDelegate = delegate;
    myDidFinish = didFinish;
    
    return self;
}
       
- (void)setup
{
    hasDestinationCoordinate = NO;
    accuracyList = [[NSArray alloc] initWithObjects:@"within 5 miles", @"within 1 mile", @"within 100 yards", nil];
    accuracyValues = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:[GreatCircleDistance milesToMeters:5]],[NSNumber numberWithInt:[GreatCircleDistance milesToMeters:1]], [NSNumber numberWithInt:100], nil]; 
    accuracyBlurb = @"Choose how close to the destination you would like your tag to go.  Be careful, this can increase the difficultly of reaching your destination.";
    
    sectionTitles = [[NSMutableArray alloc] initWithObjects:@"Name",@"Destination",@"Accuracy", @"", nil];
    sectionLabels = [[NSMutableArray alloc] initWithObjects:@"enter name",@"choose destination",[accuracyList objectAtIndex:1],@"Create Tag", nil];
    
    
    tagService = [[JTTagService alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetDestinationCoordinate:) name:@"SetDestinationCoordinate" object:nil];
    
}

- (void)viewDidLoad 
{
    //UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(showHelp:)];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTag:)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    [deleteButton release];
    
    [super viewDidLoad];    
}

- (void)viewDidUnload
{
    self.navigationItem.rightBarButtonItem = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    if( didDeleteTag )
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.tableView reloadData];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if( geoCoder ) 
        [geoCoder cancel];
    [super viewDidDisappear:animated];
}

- (void)deleteTag:(id)sender
{
    DeleteTagViewController *childController = [[DeleteTagViewController alloc] initWithTagKey:existingTagKey target:self action:@selector(didDeleteTag:)];
    [self.navigationController pushViewController:childController animated:YES];
    [childController release];
}

- (void)didDeleteTag:(NSNumber*)result
{
    didDeleteTag = [result boolValue];
}

- (void)showHelp:(id)sender
{
    HelpViewController *helpController = [[HelpViewController alloc] initWithFile:@"createTag"];
    [self presentModalViewController:helpController animated:YES];
    [helpController release];
}

- (void) createTag:(id)sender
{
    NSString *selectedAccuracy = [sectionLabels objectAtIndex:2];
    int meters = [[accuracyValues objectAtIndex:[accuracyList indexOfObject:selectedAccuracy]] intValue];
    
    if( editExistingTag )
    {
        [tagService updateTagWithKey:existingTagKey name:[sectionLabels objectAtIndex:0] destLat:destinationCoordinate.latitude destLon:destinationCoordinate.longitude destinationAccuracy:meters delegate:self didFinish:@selector(didCreateTag:) didFail:@selector(didFail:)];    
    } 
    else  
    {
        
        [tagService create:[sectionLabels objectAtIndex:0] destLat:destinationCoordinate.latitude destLon:destinationCoordinate.longitude destinationAccuracy:meters delegate:self didFinish:@selector(didCreateTag:) didFail:@selector(didFail:)];
    }
}

- (void) didCreateTag:(NSDictionary*)dict
{
    NSString *errorResponse = [dict objectForKey:@"response"];
    if( errorResponse && [errorResponse compare:@"LimitReached"] == NSOrderedSame )
    {
        NSString *message = [[NSString alloc] initWithFormat:@"You reached the limit of %d active tags.", [[dict objectForKey:@"amount"] intValue]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tag Limit Reached" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [message release];
        [alert show];
        [alert release];
        return;
    }
    if( myDelegate && [myDelegate canPerformAction:myDidFinish withSender:self] )
        [myDelegate performSelectorOnMainThread:myDidFinish withObject:nil waitUntilDone:[NSThread isMainThread]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) didFail:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Could not create tag, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.textLabel.text = [sectionLabels objectAtIndex:indexPath.section];
    cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    if( indexPath.section == 3 || indexPath.section == 4 )
    {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    } else 
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if( indexPath.section == 0 )
    {
        NewTagDetailViewController *detailController = [[NewTagDetailViewController alloc] initWithLabelText:@"Name the Tag" valueText:@"enter name" delegate:self didEnterNameSelector:@selector(didEnterName:)];
        [self.navigationController pushViewController:detailController animated:YES];
        [detailController release];
    } 
    else if( indexPath.section == 1 )  
    {
        ChooseDestinationViewController *controller = [[ChooseDestinationViewController alloc] init];
        controller.hasDefaultLocation = hasDestinationCoordinate;
        controller.defaultLocation = destinationCoordinate;
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    else if( indexPath.section == 2 )
    {        
        JTFormListViewController *formController = [[JTFormListViewController alloc] initWithLabelText:@"Choose Accuracy" detailText:accuracyBlurb listValues:accuracyList defaultValue:[sectionLabels objectAtIndex:indexPath.section] delegate:self didChooseValueSelector:@selector(didEnterAccuracy:)];
        [self.navigationController pushViewController:formController animated:YES];
        [formController release];        
        
    } else if( indexPath.section == 3 )
    {
        if( [(NSString*)[sectionLabels objectAtIndex:0] compare:@"enter name"] == NSOrderedSame )
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Blank Name" message:@"Enter a tag name please." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        if( !hasDestinationCoordinate )
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Blank Destination" message:@"Choose a destination please." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;            
        }
        [self createTag:nil];
    } 
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0)
    {
        //delete tag
    }
}

#pragma mark NewTagDetailViewController

- (void)didEnterName:(NSDictionary*)dict
{
    [sectionLabels replaceObjectAtIndex:0 withObject:[dict objectForKey:@"value"]];
    [self.tableView reloadData];
}

- (void)didEnterAccuracy:(NSDictionary*)dict
{
    [sectionLabels replaceObjectAtIndex:2 withObject:[dict objectForKey:@"value"]];   
    [self.tableView reloadData];
}

#pragma mark Notifications
- (void) SetDestinationCoordinate:(NSNotification*)notification
{
    NSDictionary *data = [notification userInfo];
    [self setDestinationCoordinateWorker:[[data objectForKey:@"lat"] doubleValue] lon:[[data objectForKey:@"lon"] doubleValue]];
}

- (void)setDestinationCoordinateWorker:(float)lat lon:(float)lon
{
    hasDestinationCoordinate = YES;
    NSString *text = [[NSString alloc] initWithFormat:@"%f , %f",lat, lon];
    [sectionLabels replaceObjectAtIndex:1 withObject:text];
    [text release];
    
    destinationCoordinate.latitude = lat;
    destinationCoordinate.longitude = lon;
    if( geoCoder ) {
        [geoCoder cancel];
        [geoCoder release];
        geoCoder = nil;
    }
    
    geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:destinationCoordinate];
    geoCoder.delegate = self;
    [geoCoder start];    
}

#pragma mark GeoCoder
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    NSString *info = [PlaceMarkFormatter standardFormat:placemark];
    [sectionLabels replaceObjectAtIndex:1 withObject:info];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSString *info = [[NSString alloc] initWithFormat:@"%1.3f..., %1.3f...",destinationCoordinate.latitude,destinationCoordinate.longitude];
    [sectionLabels removeObjectAtIndex:1];
    [sectionLabels insertObject:info atIndex:1];
    [info release];
}

#pragma mark DataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitles objectAtIndex:section];
}

- (void)dealloc 
{
    [geoCoder cancel];
    
    [sectionLabels release];
    [sectionTitles release];
    [geoCoder release];
    [tagService release];

    [accuracyList release];
    [accuracyValues release];
    [accuracyBlurb release];
    
    [super dealloc];
}

@end

