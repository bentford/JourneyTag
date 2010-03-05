//
//  PointHistoryTableViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PointHistoryTableViewController.h"
#import "TagDetailsTableViewController.h"
#import "TagImageViewController.h"
#import "DateTimeUtil.h"

@implementation PointHistoryTableViewController

- (id)initWithScore:(JTScoreType)scoreType
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    myScoreType = scoreType;
    
    isLoading = YES;
    values = [[NSMutableArray alloc] initWithObjects:[NSNull null],nil];
    scoreService = [[JTScoreService alloc] init];
    [self setTitleForScoreType:myScoreType];
    
    return self;
}

- (void)setTitleForScoreType:(JTScoreType)scoreType
{
    switch (scoreType) {
        case JTScoreTypeCarry:
            self.title = @"Carry History";
            break;
        case JTScoreTypePhoto:
            self.title = @"Photo Vote History";
            break;
    }    
}

- (void)viewDidLoad
{
    values = [[NSMutableArray alloc] initWithObjects:[NSNull null],nil];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    if( values )
    {
        [values release];
        values = nil;
    }

    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self fetchScoresForScoreType:myScoreType];
}

- (void)fetchScoresForScoreType:(JTScoreType)scoreType
{
    isLoading = YES;
    switch (myScoreType) 
    {
        case JTScoreTypeCarry:
            [scoreService getCarryScores:self didFinish:@selector(didGetScores:) didFail:@selector(didFail:)];
            break;
        case JTScoreTypePhoto:
            [scoreService getPhotoScores:self didFinish:@selector(didGetScores:) didFail:@selector(didFail:)];
            break;
    }     
}

- (void)didGetScores:(NSDictionary*)dict
{
    NSDictionary *scores = [dict objectForKey:@"scores"];
    values = [[NSMutableArray alloc] initWithCapacity:[scores count]];
    for( NSDictionary *score in scores )
    {
        [values addObject:score];
    }
    if( [scores count] == 0 )
    {
        [values addObject:[NSNull null]];
        usingDefaults = YES;
    } else
        usingDefaults = NO;
    
    isLoading = NO;
    [self.tableView reloadData];
}

- (void)didFail:(ASIHTTPRequest*)request
{
    
}

#pragma mark Table view methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if( isLoading || usingDefaults )
        return @"";
    else
        return [[[NSString alloc] initWithFormat:@"Last %d Scores",[values count]] autorelease];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [values count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *scoreData = [values objectAtIndex:indexPath.row];
    
    NSString *text;    
    NSString *detailText;
    
    if( isLoading )
    {
        usingDefaults = YES;
        text = @"Loading...";
        detailText = @"";
    } else if( [scoreData isKindOfClass:[NSNull class]] )
    {
        usingDefaults = YES;
        text = @"No points yet";
        detailText = @"Keep trying";
    } 
    else if( myScoreType == JTScoreTypePhoto )
    {
        usingDefaults = NO;
         BOOL undo = [(NSString*)[scoreData objectForKey:@"undo"] compare:@"True"] == NSOrderedSame;
         int photoVoteAward = [[scoreData objectForKey:@"photoVoteAward"] intValue];
         text = [[NSString alloc] initWithFormat:@"%@ %d Points %@", undo ? @"-" : @"+", photoVoteAward, undo ? @" (removed vote)" : @""];
         detailText = [DateTimeUtil localDateStringFromUtcString:[scoreData objectForKey:@"logDate"]];
    } 
    else if( myScoreType == JTScoreTypeCarry )
    {
        usingDefaults = NO;
        int distanceCarried = [[scoreData objectForKey:@"distanceCarried"] intValue];
        float payout = [[scoreData objectForKey:@"payout"] floatValue];
        int points = [[scoreData objectForKey:@"carryScore"] intValue];
        BOOL ownTag = (payout == 0.0);
        
        text = [[NSString alloc] initWithFormat:@"%d miles    %d points %@", distanceCarried,  points, ownTag ? @"(your tag)" : @""];
        detailText = [DateTimeUtil localDateStringFromUtcString:[scoreData objectForKey:@"logDate"]];
    } 
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = detailText;
    
    if( usingDefaults )
    {
       cell.accessoryType = UITableViewCellAccessoryNone;        
    } else
    {
       [text release];
       cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } 
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSDictionary *scoreDict = [values objectAtIndex:indexPath.row];

    if( [scoreDict isKindOfClass:[NSNull class]] )
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    if( myScoreType == JTScoreTypeCarry  )
    {
        TagDetailsTableViewController *childController = [[TagDetailsTableViewController alloc] init];
        childController.tagKey = [scoreDict objectForKey:@"tagKey"];
        childController.withinPickupRange = NO;
        childController.hasLocation = NO;
        [self.navigationController pushViewController:childController animated:YES];
        [childController release];
    } 
    if( myScoreType == JTScoreTypePhoto)
    {
        TagImageViewController *childController = [[TagImageViewController alloc] init];
        childController.photoKey = [[values objectAtIndex:indexPath.row] objectForKey:@"photoKey"];
        [self.navigationController pushViewController:childController animated:YES];
        [childController release];
    }
}

- (void)dealloc {
    [scoreService cancelReadRequests];
    [scoreService release];
    
    [values release];
    [super dealloc];
}


@end

