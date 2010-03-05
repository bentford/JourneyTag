//
//  EditTagViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 4/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditTagViewController.h"


@implementation EditTagViewController
@synthesize myTitles, myData;



- (void)viewDidLoad {
    //self.title = @"Edit Tag";
    [super viewDidLoad];
    self.myData = [[NSArray alloc] initWithObjects:@"To Portland and Back",@"Some description goes here about what you want your tag to do",nil];
    self.myTitles = [[NSArray alloc] initWithObjects:@"Name",@"Description",nil];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTag)];

}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [myTitles count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if( [indexPath row] == 0 )
    {
        [cell.textLabel setText: [myTitles objectAtIndex:[indexPath section]]];
    }
    if( [indexPath row] == 1 )
    {
        [cell.textLabel setText:[myData objectAtIndex:[indexPath section]]];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


#pragma mark IBActions

- (IBAction) cancelModal:(id)sender
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [myData release];
    [myTitles release];
    [super dealloc];
}


@end
