//
//  GameViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import "GameViewController.h"
#import "HighScoreViewController.h"

@implementation GameViewController

- (void)awakeFromNib {
	self = [super initWithStyle:UITableViewStyleGrouped];
	self.title = @"Game";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = @"High Scores";
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	HighScoreViewController *childController = [[HighScoreViewController alloc] init];
	[self.navigationController pushViewController:childController animated:YES];
	[childController release];
}

- (void)dealloc {
    [super dealloc];
}

@end

