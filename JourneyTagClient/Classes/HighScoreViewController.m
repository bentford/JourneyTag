//
//  HighScoreViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import "HighScoreViewController.h"
#import "JTGameService.h"


@interface HighScoreViewController(PrivateMethods)
- (void)setupTitleView;
@end

@interface HighScoreViewController()
@property (nonatomic,retain) NSArray *accounts;
@end

@implementation HighScoreViewController
@synthesize accounts;

- (id)init {
	if( self = [super initWithStyle:UITableViewStylePlain] ) {
		self.accounts = [NSArray array];
		gameService = [[JTGameService alloc] init];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	//self.title = @"Highscores Overall";
    
    [self setupTitleView];
    
	[gameService getAccountsByHighScoreWithDelegate:self didFinish:@selector(didLoadAccounts:) didFail:@selector(didFail:)];
	
}

#pragma mark JTGameService
- (void)didLoadAccounts:(NSDictionary *)data {
	self.accounts = [data objectForKey:@"accounts"];
	[self.tableView reloadData];
}

- (void)didFail:(ASIHTTPRequest *)request {
	
}
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, [[self.accounts objectAtIndex:indexPath.row] objectForKey:@"username"]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ points", [[self.accounts objectAtIndex:indexPath.row] objectForKey:@"score"]];
    
    return cell;
}

- (void)dealloc {
	[gameService release];
	self.accounts = nil;
	
    [super dealloc];
}


@end

@implementation HighScoreViewController(PrivateMethods)
// Trying out using a xib for a simple view
// What is the benifit to this:
// Good:
// -Easier to modify the view
// Bad:
// -Loading is more complex.

- (void)setupTitleView {
    NSArray *parts = [[NSBundle mainBundle] loadNibNamed:@"TitleView" owner:nil options:nil];
    UIView *titleView = [parts objectAtIndex:0];
    
    UILabel *titleLabel = (UILabel *)[titleView viewWithTag:1];
    UILabel *subTitleLabel = (UILabel *)[titleView viewWithTag:2];
    titleLabel.text = @"Highscores Overall";
    subTitleLabel.text = @"Top 200";
    
    self.navigationItem.titleView = titleView;
}
@end