//
//  GameViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import "GameViewController.h"
#import "HighScoreViewController.h"
#import "LatestPhotoViewController.h"

@implementation GameViewController

- (void)awakeFromNib {
	self = [super initWithStyle:UITableViewStyleGrouped];
	self.navigationItem.title = @"Game Info";
    titles = [[NSArray alloc] initWithObjects:@"High Scores", @"Latest Photos", nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain  target:nil action:nil] autorelease];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [titles count];
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
    
	cell.textLabel.text = [titles objectAtIndex:indexPath.section];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
    UIViewController *childController;
    switch (indexPath.section) {
        case 0:
            childController = [[HighScoreViewController alloc] init];
            break;
        case 1:
            childController = [[LatestPhotoViewController alloc] init];
            break;
        default:
            break;
    }
    childController.hidesBottomBarWhenPushed = YES;
    
	[self.navigationController pushViewController:childController animated:YES];
	[childController release];
}

- (void)dealloc {
    [super dealloc];
}

@end

