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
#import "AppSettings.h"

@interface GameViewController()
@property (nonatomic, retain) UITableView *tableView;
@end

@implementation GameViewController
@synthesize tableView=myTableView;

- (void)awakeFromNib {
    self.navigationItem.title = @"Game Info";
    titles = [[NSArray alloc] initWithObjects:@"High Scores", @"Latest Photos", nil];
    
    hideAdHelper = [[HideAdHelper alloc] init];
    hideAdHelper.delegate = self;
}

- (void)loadView {
    [super loadView];
	
    
    
    adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 318, 320, 50)];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
    adView.delegate = self;
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if( kTestAdLoadFailureAnimation == YES )
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:hideAdHelper selector:@selector(hideBannerView) userInfo:nil repeats:NO];
    
}

#pragma mark HideAdHelperDelegate
- (UIView *)mainView {
    return myTableView;
}

- (UIView *)bannerView {
    return adView;
}
#pragma mark -

#pragma mark ADBannerViewDelegate
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [hideAdHelper hideBannerView];
}
#pragma mark -

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
    
    [myTableView release];
    
    adView.delegate = nil;
    [adView release];
    
    [hideAdHelper release];
    
    [super dealloc];
}

@end

