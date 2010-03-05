//
//  ScoreBreakdownTableViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 7/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ScoreBreakdownTableViewController.h"
#import "TableCellUtil.h"
#import "PointHistoryTableViewController.h"

@implementation ScoreBreakdownTableViewController

- (id)initWithCarryScore:(NSInteger)carryScore photoScore:(NSInteger)photoScore
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    myCarryScore = carryScore;
    myPhotoScore = photoScore;
    return self;
}

- (void)viewDidLoad 
{
    self.title = @"Points";
    
    NSString *carryScoreText = [[NSString alloc] initWithFormat:@"%d points",myCarryScore];
    NSString *photoScoreText = [[NSString alloc] initWithFormat:@"%d points",myPhotoScore];
    
    cellLabels = [[NSArray alloc] initWithObjects:@"Carry Score", @"Photo Score", nil];
    cellValues = [[NSArray alloc] initWithObjects:carryScoreText, photoScoreText, nil];

    sectionTitles = [[NSArray alloc] initWithObjects:@"Earnings",@"Help",nil];
    [carryScoreText release];
    [photoScoreText release];
    
    helpCellHeight = 1200;
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [cellLabels release];
    cellLabels = nil;
    
    [cellValues release];
    cellValues = nil;
    
    [sectionTitles release];
    sectionTitles = nil;
    
    self.title = nil;
    [super viewDidUnload];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( section == 0 )
        return [cellValues count];

    if( section == 1 )
        return 1;

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitles objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    
    if( indexPath.section == 0 )
    {
        [TableCellUtil setupMediumLabeledCell2:cell labelText:[cellLabels objectAtIndex:indexPath.row] valueText:[cellValues objectAtIndex:indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if( indexPath.section == 1)
    {
        [TableCellUtil setupWebViewCell:cell filename:@"points" height:helpCellHeight];
    }
    

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 1 && indexPath.row == 0 )
    {
        return helpCellHeight;
    } else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    PointHistoryTableViewController *childController = [[PointHistoryTableViewController alloc] initWithScore:(JTScoreType)indexPath.row];
    [self.navigationController pushViewController:childController animated:YES];
    [childController release];
}

- (void)dealloc {
    [cellLabels release];
    [cellValues release];    
    [sectionTitles release];
    
    [super dealloc];
}


@end

