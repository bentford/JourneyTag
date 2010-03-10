//
//  TestBaseTableViewController.m
//  JTTestHarness1
//
//  Created by Ben Ford on 8/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TestBaseTableViewController.h"


@implementation TestBaseTableViewController

- (void)awakeFromNib
{
    accountService = [[JTAccountService alloc] init];
    markService = [[JTMarkService alloc] init];
    photoService = [[JTPhotoService alloc] init];
    tagService = [[JTTagService alloc] init];
    depotService = [[JTDepotService alloc] init];    
    inventoryService = [[JTInventoryService alloc] init];
    scoreService = [[JTScoreService alloc] init];
    titles = [[NSMutableArray alloc] initWithCapacity:1];
    [titles addObject:@"start"];
    [self.tableView reloadData];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [titles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if( indexPath.row == 0  )
        [self runTestStructure];
}

- (void) runTestStructure
{
    
}

- (void) updateTable:(NSString*)message
{
    [titles addObject:message];
    [self.tableView reloadData];
}

- (void)dealloc {
    [super dealloc];
}


@end

