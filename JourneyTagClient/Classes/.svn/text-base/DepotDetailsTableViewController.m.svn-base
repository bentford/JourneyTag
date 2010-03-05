//
//  DepotDetailsTableViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 5/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DepotDetailsTableViewController.h"
#import "TagHistoryViewController.h"
#import "DepotImageViewController.h"
#import "TableCellUtil.h"
#import "DateTimeUtil.h"

@implementation DepotDetailsTableViewController

- (id)initWithDepotKey:(NSString*)depotKey
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    depotService = [[JTDepotService alloc] init];
    myDepotKey = [depotKey retain];
    return self;
}

- (void)viewDidLoad {
    self.title = @"Depot Details";

    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Pickup Depot" style:UIBarButtonItemStylePlain target:self action:@selector(confirmDepotPickup)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];

    labels = [[NSArray alloc] initWithObjects:@"Name:",@"Dropped:", nil];
    sections = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:[labels count]], [NSNumber numberWithInt:1], nil];
    
    [super viewDidLoad];
}

-(void)viewDidUnload
{
    self.title = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [labels release];
    labels = nil;
    
    [super viewDidUnload];
}
- (void)viewDidAppear:(BOOL)animated
{
    [self refreshData];
    [super viewDidAppear:animated];
}

- (void) refreshData
{
    [depotService get:myDepotKey delegate:self didFinish:@selector(didLoadDepot:) didFail:@selector(didFail:)];
}
#pragma mark JTService
- (void) didLoadDepot:(NSDictionary*)dict
{
    if( myPhotoKey ) {
        [myPhotoKey release];
        myPhotoKey = nil;
    }
    myPhotoKey = [[dict objectForKey:@"photo"] retain];
    
    NSString *name = [[NSString alloc] initWithFormat:@"Depot #%@",[dict objectForKey:@"number"]];
    
    if( list ) {
        [list release];
        list = nil;
    }
    list = [[NSArray alloc] initWithObjects:
            name,
            [DateTimeUtil localDateStringFromUtcString:[dict objectForKey:@"dateDropped"]],
            nil];
    [name release];
    
    [self.tableView reloadData];
}

- (void) didFail:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Operation Failed" message:nil delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark ActionSheet
- (void)confirmDepotPickup
{
    UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:@"Reminder:  Depot pickups cannot be undone" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Confirm Pickup" otherButtonTitles:nil];
    [confirm showInView:self.parentViewController.tabBarController.view];
    [confirm release];
}

- (void) actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 )
    {
        [self pickupDepot];
    }
}

#pragma mark JTService
- (void) pickupDepot
{
    [depotService pickup:myDepotKey delegate:self didFinish:@selector(didPickupDepot:) didFail:@selector(didFail:)];
}

- (void) didPickupDepot:(NSDictionary*)dict
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[sections objectAtIndex:section] intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"cell"] autorelease];
    
    if( indexPath.section == 0 )
    {
        //cell.textLabel.text = [list objectAtIndex:indexPath.row];
        [TableCellUtil setupCustomCell:cell labelText:[labels objectAtIndex:indexPath.row] valueText:[list objectAtIndex:indexPath.row]];
    }  
    else if( indexPath.section == 1 )
    {
        cell.textLabel.text = @"Depot Image";
    }
    
    if( indexPath.section == 1) 
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{

    if( indexPath.section == 1 )
    {
        DepotImageViewController *childController = [[DepotImageViewController alloc] initWithPhotoKey:myPhotoKey];
        
        [self.navigationController pushViewController:childController animated:YES];        
        [childController release];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)dealloc {
    [depotService cancelReadRequests];
    [depotService release];
    
    [myDepotKey release];
    [myPhotoKey release];
    [list release];
    [labels release];
    
    [super dealloc];
}
@end

