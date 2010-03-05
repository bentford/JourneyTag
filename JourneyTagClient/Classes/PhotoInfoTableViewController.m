//
//  PhotoInfoTableViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 7/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PhotoInfoTableViewController.h"

@implementation PhotoInfoTableViewController
@synthesize currentIndex, date;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.view.frame = CGRectMake(0, 0, 320, 460);
    return self;
}

#pragma mark Table view methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Date Taken";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = date;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)dealloc {
    [date release];
    
    [super dealloc];
}


@end

