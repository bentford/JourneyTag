//
//  LevelHelpTableViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 7/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ActivityHelpTableViewController.h"
#import "TableCellUtil.h"

@implementation ActivityHelpTableViewController

- (id)initWithStyle:(UITableViewStyle)style helpMode:(ActivityHelpMode)mode
{
    self = [super initWithStyle:style];
    
    myMode = mode;
    payoutUtil = [[JTPayoutUtility alloc] init];
    
    rowCount[0] = 1;
    rowCount[1] = 50;
    detailArray = [[NSMutableArray alloc] initWithCapacity:rowCount[1]];
    helpCellHeight = 110;
    return self;
}



- (void)fillLevelArray
{
    int maxLevel = rowCount[1];
    NSArray *levelScores = [payoutUtil generateLevelScores:maxLevel];
    for(int level = 1; level <= maxLevel; level++ )
    {
        int points = [[levelScores objectAtIndex:level-1] intValue];
        NSString *rowText = [[NSString alloc] initWithFormat:@"Level %d - %d points",level, points];
        [detailArray addObject:rowText];
        [rowText release];
    }
}

- (void)fillPayoutArray
{
    int maxLevel = rowCount[1];
    NSArray *levelScores = [payoutUtil generateLevelScores:maxLevel];
    for(int level = 1; level <= maxLevel; level++ )
    {
        int points = [[levelScores objectAtIndex:level-1] intValue];
        NSString *rowText = [[NSString alloc] initWithFormat:@"Level %d - %1.2f pt/mile",level, [payoutUtil calculatePayoutForCarryScore:points] ];
        [detailArray addObject:rowText];
        [rowText release];
    }
}

- (void)display
{
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    if( myMode == ActivityHelpLevel )
        [self fillLevelArray];
    if( myMode == ActivityHelpPayout )
        [self fillPayoutArray];
       
    sectionTitleList = [[NSArray alloc] initWithObjects:@"Level Help", @"Payout Help",nil];
    detailSectionTitleList = [[NSArray alloc] initWithObjects:@"Required points per level ", @"Payout per level",nil];
}

#pragma mark Table view methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 && indexPath.row == 0 )
    {
        return helpCellHeight;
    } else {
        return 50;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if( section == 0 )
    {
        return [sectionTitleList objectAtIndex:(int)myMode];
    }
    if (section == 1 )
    {
        return [detailSectionTitleList objectAtIndex:(int)myMode];
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rowCount[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( indexPath.section == 0 )
    {
        static NSString *cellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if( !cell )
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease]; 
        }
            
        if( myMode == ActivityHelpLevel )
            [TableCellUtil setupWebViewCell:cell filename:@"levels" height:helpCellHeight];
        if( myMode == ActivityHelpPayout )
            [TableCellUtil setupWebViewCell:cell filename:@"payout" height:helpCellHeight];
        return cell;
    } else {
        static NSString *cellIdentifier2 = @"Cell2";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) 
        {
            UITableViewCellStyle style = myMode == ActivityHelpLevel ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
            
            cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:cellIdentifier2] autorelease];
        }
        
        cell.textLabel.text = [detailArray objectAtIndex:indexPath.row];
        if( myMode == ActivityHelpLevel && indexPath.row <= 18 && (indexPath.row+1) % 2 == 0  )
        {
            NSString *depotMessage = [[NSString alloc] initWithFormat:@"earn depot #%d", ((indexPath.row+1)/2)+1];
            cell.detailTextLabel.text = depotMessage;
            [depotMessage release];
        } else {
            cell.detailTextLabel.text = @"";
        }
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)dealloc {
    [sectionTitleList release];    
    [detailSectionTitleList release];
    
    [detailArray release];
    
    [payoutUtil release];
    [super dealloc];
}


@end

