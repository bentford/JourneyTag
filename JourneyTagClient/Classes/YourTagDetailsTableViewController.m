//
//  YourTagDetailsTableViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 9/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "YourTagDetailsTableViewController.h"
#import "NewTagViewController2.h"

@implementation YourTagDetailsTableViewController

- (void)viewDidAppear:(BOOL)animated
{
    if( hasArrivedAtFinalDestination )
    {
        self.navigationItem.rightBarButtonItem = nil;            
    } 
    else 
    {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editThisTag:)];
        self.navigationItem.rightBarButtonItem = editButton;
        [editButton release];
    }
    [super viewDidAppear:animated];
}

- (void) didLoadTag:(NSDictionary*)dict
{
    [super didLoadTag:dict];
}

- (void)viewDidLoad
{
    //moved rightBarButtonItem instantiation to viewDidAppear to stop weird caching behavior
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.navigationItem.rightBarButtonItem = nil;
    
    [super viewDidUnload];
}

- (void)editThisTag:(id)sender {
    
    //ignore this button until the tag has been loaded
    if( didLoadTag == NO )
        return;
    
    NSString *name = [infoSectionValues objectAtIndex:0];
    
    NewTagViewController2 *childController = [[NewTagViewController2 alloc] initWithTagKey:tagKey name:name destinationCoordinate:destinationCoordinate accuracyInMeters:currentAccuracy delegate:self didFinish:@selector(didFinishEditing:)];
    
    [self.navigationController pushViewController:childController animated:YES];
    [childController release];
}

- (void)didFinishEditing:(id)sender
{
    [self refreshData];
}
@end
