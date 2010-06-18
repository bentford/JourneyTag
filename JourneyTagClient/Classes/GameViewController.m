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
#import <iAd/iAd.h>

@interface GameViewController()
@property (nonatomic, retain) UITableView *tableView;
@end

@implementation GameViewController
@synthesize tableView=myTableView;

- (void)awakeFromNib {
    self.navigationItem.title = @"Game Info";
    titles = [[NSArray alloc] initWithObjects:@"High Scores", @"Latest Photos", nil];
}

- (void)loadView {
    [super loadView];
	
    
    
    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 318, 320, 50)];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
    [self.view addSubview:adView];
    
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 318) style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain  target:nil action:nil] autorelease];
}

#pragma mark UITableViewDataSource
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
#pragma mark -

#pragma mark UITableViewDelegate
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
#pragma mark -
- (void)dealloc {
    [super dealloc];
}

@end

