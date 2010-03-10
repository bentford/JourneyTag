//
//  ActivityViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 9/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ActivityViewController.h"
#import "SignInViewController.h"
#import "ActivityButtonUtil.h"
#import "ActivityHelpTableViewController.h"
#import "ScoreBreakdownTableViewController.h"
#import "AccountSettingsViewController.h"
#import "GenericWebViewController.h"
#import "AppCheckOperation.h"
#import "JTGlobal.h"
#import "NetworkUtil.h"
#import "AppSettings.h"

#define kTableViewTag 5
@implementation ActivityViewController

- (void) awakeFromNib
{
    self.title = @"Refreshing";
    accountService = [[JTAccountService alloc] init];
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = view;
    [view release];
                    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 367) style:UITableViewStyleGrouped];
    myTableView.tag = kTableViewTag;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createRefreshButton:self action:@selector(refreshData)];
}

- (void)viewDidLoad 
{       
    [self setupDefaultTableData];    
    [myTableView reloadData];    
    
    [super viewDidLoad];    
}

- (void)viewDidUnload
{
    self.navigationItem.leftBarButtonItem = nil;
    
    [myTableView removeFromSuperview];
    [myTableView release];
    myTableView = nil;
    
    self.view = nil;
    
    if( labels)
    {
        [labels release];
        labels = nil;
    }
    if( list)
    {
        [list release];
        list = nil;
    }
    if( sectionTitles)
    {
        [sectionTitles release];
        sectionTitles = nil;
    }
    
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setupDefaultTableData]; //required before refreshData is called
    [self refreshData];    
    [myTableView reloadData];    
    
    [super viewDidAppear:animated];
}

- (void)setupDefaultTableData
{
    NSArray *list1 = [[NSArray alloc] initWithObjects:@"?",@"?",nil];
    NSArray *list2 = [[NSArray alloc] initWithObjects:@"?",@"?", nil];
    NSArray *list3 = [[NSArray alloc] initWithObjects:@"?",@"?",@"?",nil];
    NSArray *list4 = [[NSArray alloc] initWithObjects:@"",nil];
    NSArray *list5 = [[NSArray alloc] initWithObjects:@"",nil];
    
    NSArray *labels1 = [[NSArray alloc] initWithObjects:
                        @"Score:", 
                        @"Next level in:", 
                        nil];
    
    
    NSArray *labels2 = [[NSArray alloc] initWithObjects:
                        @"Level:", 
                        @"Payout:", 
                        nil];
    
    NSArray *labels3 = [[NSArray alloc] initWithObjects:
                        @"Traveled:", 
                        @"Carried:", 
                        @"Total Drops:", 
                        nil];
    NSArray *labels4 = [[NSArray alloc] initWithObjects:@"Account Settings",nil];
    NSArray *labels5 = [[NSArray alloc] initWithObjects:@"About",nil];
    
    if( labels ) {
        [labels release];
        labels = nil;
    }
    if( list ) {
        [list release];
        list = nil;
    }
    
    labels = [[NSArray alloc] initWithObjects:labels1,labels2,labels3,labels4,labels5,nil];
    list = [[NSArray alloc] initWithObjects:list1,list2,list3,list4,list5,nil];
    
    [labels1 release]; [labels2 release]; [labels3 release]; [labels4 release];[labels5 release];
    [list1 release]; [list2 release]; [list3 release]; [list4 release];[list5 release];
    
    if( sectionTitles )
        [sectionTitles release];
    
    sectionTitles = [[NSArray alloc] initWithObjects:@"Points",@"Level",@"Distance",@"",@"",nil];    
}

- (void)didCheckApp:(NSNumber*)valid
{
    if( ![valid boolValue] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh No" message:@"It appears this app was not paid for.  This really bums me out because I worked very hard to make this app possible.  Yes, I'm not a company, but a solo developer.  Please consider purchasing a copy." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];         
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( [alertView.title compare:@"Phone Blocked"] == NSOrderedSame)
    {
        exit(0);
    }
    [accountService reportPirateWithUuid:[UIDevice currentDevice].uniqueIdentifier delegate:self didFinish:@selector(didReportPirate:) didFail:@selector(didFail:)];
}

- (void)didReportPirate:(NSDictionary*)dict
{
    if( [(NSString*)[dict objectForKey:@"response"] compare:@"OkForNow"] != NSOrderedSame )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phone Blocked" message:@"I pay for the server with app store revenue.  Your usage has become to high and I had to block your account.  Consider buying the app in the store." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release]; 
        
    }
}

- (void) refreshData
{
    if( [accountService hasSignInCookie] ) 
    {
        self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createActivityIndicatorButton];
        
        [NetworkUtil checkForNetwork];
        [accountService getAccountInfo:self didFinish:@selector(didGetAccountInfo:) didFail:@selector(didFail:)];
        
        UIBarButtonItem *signInButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOut:)];
        self.navigationItem.rightBarButtonItem = signInButton;
        [signInButton release];
    } else {
        self.title = @"Not Logged In";
        
        [self signIn:nil];
    }
}

- (void) didGetAccountInfo:(NSDictionary*)dict
{
    NSString *username = [dict objectForKey:@"username"];
    
    [JTGlobal sharedGlobal].username = username; //important
    
    if( [username length] == 0 )
    {
        self.title= @"Not Logged In";
        [self signOut:nil]; //they have an invalid login cookie, so sign them out!!
        [self signIn:nil];
        return;
    }
    
    self.title = username;            
    
    carryScore = [[dict objectForKey:@"carryScore"] intValue];
    photoScore = [[dict objectForKey:@"photoScore"] intValue];
    
    NSString *score = [[NSString alloc] initWithFormat:@"%@ points",[dict objectForKey:@"score"]];
    NSString *payout = [[NSString alloc] initWithFormat:@"%@ points/mile",[dict objectForKey:@"payout"]];
    NSString *levelUp = [[NSString alloc] initWithFormat:@"%@ points",[dict objectForKey:@"pointsNeededForNextLevel"]];
    
    NSString *traveled = [[NSString alloc] initWithFormat:@"%@ miles", [dict objectForKey:@"totalDistanceTraveled"]];
    NSString *carried = [[NSString alloc] initWithFormat:@"%@ miles", [dict objectForKey:@"totalDistanceCarried"]];
    
    NSArray *list1 = [[NSArray alloc] initWithObjects:
                      score, 
                      levelUp,         
                      nil];
    
    NSArray *list2 = [[NSArray alloc] initWithObjects:
                      [dict objectForKey:@"level"], 
                      payout,
                      nil];
    
    NSArray *list3 = [[NSArray alloc] initWithObjects:
                      traveled, 
                      carried,
                      [dict objectForKey:@"totalDrops"], 
                      nil];    
    if( list ) {
        [list release];
        list = nil;
    }
    list = [[NSArray alloc] initWithObjects:list1,list2,list3,nil];
    
    [score release];
    [payout release];
    [levelUp release];
    [traveled release];
    [carried release];
    
    [list1 release]; [list2 release]; [list3 release];
    
    
    self.navigationItem.leftBarButtonItem = [ActivityButtonUtil createRefreshButton:self action:@selector(refreshData)];
    [myTableView reloadData];
}

#pragma mark Sign In
-(void) signIn:(id)sender
{
    SignInViewController *controller = [[SignInViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [controller release];
    
    [self presentModalViewController:navController animated:YES];
    [navController release];
}

- (void ) signOut:(id)sender
{
    [accountService logout:self didFinish:@selector(didSignOut:) didFail:@selector(didFail:)];
    [accountService deleteCookie];
}

- (void)didSignOut:(NSDictionary*)dict
{
    [self refreshData];    
}

- (void)didFail:(ASIHTTPRequest*)request
{
    [self signOut:nil];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [labels count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[labels objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    UITableViewCell *cell;
    if( indexPath.section == 3 || indexPath.section == 4 )
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settings"] autorelease];
        cell.textLabel.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } 
    else 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 25)];
        label.textAlignment = UITextAlignmentRight;
        label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]-5];
        label.text = [[labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 130, 25)];
        text.textAlignment = UITextAlignmentLeft;
        text.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        text.text = [[list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:text];
        
        [label release];
        [text release];
    }
    
    if( indexPath.section == 1  || indexPath.section == 3 || indexPath.section == 4 || (indexPath.section == 0 && indexPath.row == 0 ) )
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( indexPath.section == 0 && indexPath.row == 0 )
    {
        ScoreBreakdownTableViewController *childController = [[ScoreBreakdownTableViewController alloc] initWithCarryScore:carryScore photoScore:photoScore];
        childController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:childController animated:YES];
        [childController release];
    } else if( indexPath.section == 1 )
    {
        BOOL hasHelp = NO;
        ActivityHelpMode mode;
        if(  indexPath.row == 0 )
        {
            hasHelp = YES;
            mode = ActivityHelpLevel;
        }
        if( indexPath.row == 1 )
        {
            hasHelp = YES;
            mode = ActivityHelpPayout;
        }
        
        if( hasHelp )
        {
            ActivityHelpTableViewController *childController = [[ActivityHelpTableViewController alloc] initWithStyle:UITableViewStyleGrouped helpMode:mode];
            childController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:childController animated:YES];
            
            [childController release];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        
    } else if( indexPath.section == 3 )
    {
        AccountSettingsViewController *childController = [[AccountSettingsViewController alloc] init];
        childController.hidesBottomBarWhenPushed = NO;
        [self.navigationController pushViewController:childController animated:YES];
        [childController release];
    } else if (indexPath.section == 4 )
    {
        GenericWebViewController *childController = [[GenericWebViewController alloc] initWithFilename:@"about"];
        childController.title = @"About";
        childController.hidesBottomBarWhenPushed = NO;
        [self.navigationController pushViewController:childController animated:YES];
        [childController release];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitles objectAtIndex:section];
}

#pragma mark ARRollerDelegate
- (NSString *)adWhirlApplicationKey
{
    return [AppSettings adWhirlApplicationKey];
}

- (void)dealloc {
    [accountService cancelReadRequests];    
    [accountService release];
    [list release];
    [labels release];
    [sectionTitles release];
    [myTableView release];
    
    [super dealloc];
}

@end
