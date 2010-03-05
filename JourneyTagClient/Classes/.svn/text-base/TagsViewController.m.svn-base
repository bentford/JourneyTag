//
//  TagsViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 4/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagsViewController.h"
#import "NewTagViewController2.h"
#import "TagHistoryViewController.h"
#import "YourTagDetailsTableViewController.h"
#import "ActivityButtonUtil.h"
#import "AppSettings.h"
#import "AppFiles.h"
#import "DateTimeUtil.h"
#import "LogUtil.h"
#import "ProblemCodeUtil.h"

@implementation TagsViewController
@synthesize list;

- (void)awakeFromNib
{
    self.title = @"Your Tags";
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = [AppSettings distanceFilter];
    locationManager.desiredAccuracy = [AppSettings desiredAccuracy];    
    locationManager.delegate = self;
    
    tagService = [[JTTagService alloc] init];
       
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTagViewLog:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];

    [super awakeFromNib];
}

- (void) saveTagViewLog:(id)sender
{
    [tagViewLog writeToFile:[AppFiles pathForTagViewLog] atomically:YES];
}

#pragma mark init
- (void)viewDidLoad
{
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newTag)];
    self.navigationItem.rightBarButtonItem = newButton;
    [newButton release];
    
    self.navigationItem.leftBarButtonItem = [self createRefreshButton]; 
    
    sectionTitles = [[NSArray alloc] initWithObjects:@"In Transit",@"Finished",nil];
    
    tagViewLog = [[NSMutableDictionary alloc] initWithContentsOfFile:[AppFiles pathForTagViewLog]];
    if( !tagViewLog )
        tagViewLog = [[NSMutableDictionary alloc] initWithCapacity:0];

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
    [sectionTitles release];
    
    [self saveTagViewLog:nil];
    [tagViewLog release];
    
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [locationManager startUpdatingLocation];
    [self refreshTags:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [locationManager stopUpdatingLocation];   
}

- (UIBarButtonItem*) createRefreshButton
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTags:)];
    [button autorelease];
    return button;
}

#pragma mark UITableViewDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 0 )
    {
        return [list count];    
    } 
    if( section == 1 )
    {
        return [completedList count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitles objectAtIndex:section];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *identifier = @"id";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if( cell == nil )
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
    }

    if( isUpdatingTable )
    {
        cell.textLabel.text = @"";
        return cell;
    }  
    
    cell.detailTextLabel.text = @""; //required or else there will be leftovers
    
    if( indexPath.section == 0 )
    {
        cell.textLabel.text = [list objectAtIndex:indexPath.row];
        int problemCode = [[problemCodeList objectAtIndex:indexPath.row] intValue];
        if( problemCode > 0 )
        {
            NSString *text = [[NSString alloc] initWithFormat:@"Destination Problem: %@",[ProblemCodeUtil problemCodeToString:problemCode]];
            cell.detailTextLabel.text = text; [text release];
            cell.detailTextLabel.textColor = [UIColor orangeColor];            
        } else if( [[notDroppedStatusList objectAtIndex:indexPath.row] boolValue] )
        {
            cell.detailTextLabel.text = @"Not Dropped";
            cell.detailTextLabel.textColor = [UIColor blueColor];            
        } else if( [[tagActivityList objectAtIndex:indexPath.row] boolValue] ) 
        {
            cell.detailTextLabel.text = @"Recent Activity";
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
    }
        
    if( indexPath.section == 1 )
    {
        cell.textLabel.text = [completedList objectAtIndex:indexPath.row];    
        if( [[finishedTagActivityList objectAtIndex:indexPath.row] boolValue] ) 
        {
            cell.detailTextLabel.text = @"Recently Finished";
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    YourTagDetailsTableViewController *childController = [[YourTagDetailsTableViewController alloc] init];
    NSString *tagKey;
    if( indexPath.section == 0 )
    {
        tagKey = [keyList objectAtIndex:indexPath.row];
    }
    if( indexPath.section == 1 )
    {
        tagKey = [completedKeyList objectAtIndex:indexPath.row];    
    }

    [tagViewLog setObject:[NSDate date] forKey:[LogUtil logKeyForString:tagKey]];
    //[self saveTagViewLog:nil]; //causes noticable lag
    
    childController.tagKey = tagKey;
    childController.currentLocation = locationManager.location.coordinate;
    childController.hasLocation = hasLocation;
    
    childController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:childController animated:YES];
    [childController release];    
}


#pragma mark JTTagServiceDelegate

- (void) didLoadTags:(NSDictionary*)dict
{
    NSArray *tags = [dict objectForKey:@"tags"];
    int capacity = 0;//[tags count]; 
    
    self.list = [[NSMutableArray alloc] initWithCapacity:capacity];
    [self.list release];
    
    if( keyList )
        [keyList release];
    keyList = [[NSMutableArray alloc] initWithCapacity:capacity];    
    
    
    [completedList release];
    completedList = [[NSMutableArray alloc] initWithCapacity:capacity];    
    
    [completedKeyList release];
    completedKeyList = [[NSMutableArray alloc] initWithCapacity:capacity];    

    [completedDateCreatedList release];
    completedDateCreatedList = [[NSMutableArray alloc] initWithCapacity:capacity];    
    
    [dateCreatedList release];
    dateCreatedList = [[NSMutableArray alloc] initWithCapacity:capacity];    
    
    [tagActivityList release];
    tagActivityList = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    [notDroppedStatusList release];
    notDroppedStatusList = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    [finishedTagActivityList release];
    finishedTagActivityList = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    [problemCodeList release];
    problemCodeList = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    for( NSDictionary* tag in tags)
    {
        NSString *tagKey = [tag objectForKey:@"key"];
        
        if( [(NSString*)[tag objectForKey:@"hasReachedDestination"] compare:@"True"] == NSOrderedSame )
        {
            [completedList addObject:[tag objectForKey:@"name"]];
            [completedKeyList addObject:tagKey];
            [completedDateCreatedList addObject:[tag objectForKey:@"dateCreated"]];
            
            //---- recent activity detection
            NSDate *lastUpdated = [DateTimeUtil localDateFromUtcString:[tag objectForKey:@"lastUpdated"]];
            NSDate *lastViewed = [tagViewLog objectForKey:[LogUtil logKeyForString:tagKey]];
            
            //show indicator if:
            //-you never viewed it or it's been updated since you last viewed it
            if( !lastViewed || [lastViewed compare:lastUpdated] == NSOrderedAscending )
                [finishedTagActivityList addObject:[NSNumber numberWithBool:YES]]; //activity happend
            else 
                [finishedTagActivityList addObject:[NSNumber numberWithBool:NO]]; 
        } else {
            [list addObject:[tag objectForKey:@"name"]];
            [keyList addObject:tagKey];
            [dateCreatedList addObject:[tag objectForKey:@"dateCreated"]];
            
            //--- on first drop detection
            int markCount = [[tag objectForKey:@"markCount"] intValue];
            BOOL notOnFirstDrop = markCount > 1;
            
            //---- new tags detection ----
            NSNumber *notDropped = [NSNumber numberWithBool:[(NSString*)[tag objectForKey:@"status"] compare:@"new"] == NSOrderedSame];
            [notDroppedStatusList addObject:notDropped];
            
            //---- recent activity detection
            NSDate *lastUpdated = [DateTimeUtil localDateFromUtcString:[tag objectForKey:@"lastUpdated"]];
            NSDate *lastViewed = [tagViewLog objectForKey:[LogUtil logKeyForString:tagKey]];
            
            //show indicator on one condition:
            //-you didn't just drop it
            //AND
            //-you never viewed it or it's been updated since you last viewed it
            
            //if lastViewed is earlier than lastUpdated
            if(notOnFirstDrop && ( !lastViewed || [lastViewed compare:lastUpdated] == NSOrderedAscending ) )
                [tagActivityList addObject:[NSNumber numberWithBool:YES]]; //activity happend
            else 
                [tagActivityList addObject:[NSNumber numberWithBool:NO]]; 
            
            NSNumber *problemCode = [[NSNumber alloc] initWithInt:[[tag objectForKey:@"problemCode"] intValue]];
            [problemCodeList addObject:problemCode];
            [problemCode release];
        }
    }
    
    self.navigationItem.leftBarButtonItem = [self createRefreshButton];
    
    isUpdatingTable = NO;
    [self.tableView reloadData];
}

- (void) didFail:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Operation Failed" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark menu actions
-(void)newTag
{
    NewTagViewController2 *childController = [[NewTagViewController2 alloc] init];
    [self.navigationController pushViewController:childController animated:YES];    
    [childController release];
}

- (void) refreshTags:(id)sender
{
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createActivityIndicatorButton];
    
    self.list = [[NSMutableArray alloc] initWithObjects:@"Loading...", nil];
    [self.list release];
    
    isUpdatingTable = YES;
    [tagService getAllForYourAccount:self didFinish:@selector(didLoadTags:) didFail:@selector(didFail:)];
}

#pragma mark LocationManager
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    hasLocation = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    hasLocation = NO;
}

- (void)dealloc 
{
    [list release];
    [keyList release];
    [completedList release];
    [completedKeyList release];
    [completedDateCreatedList release];
    [dateCreatedList release];
    [notDroppedStatusList release];
    [finishedTagActivityList release];
    
    [sectionTitles release];
    
    [locationManager stopUpdatingLocation];
    [locationManager release];

    [tagViewLog release];
    [tagActivityList release];
    
    [tagService cancelReadRequests];
    [tagService release];
    
    [super dealloc];
}


@end
