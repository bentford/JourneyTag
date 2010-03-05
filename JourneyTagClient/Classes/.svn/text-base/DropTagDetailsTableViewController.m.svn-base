//
//  DropTagDetailsTableViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 9/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DropTagDetailsTableViewController.h"

@implementation DropTagDetailsTableViewController

- (void)viewDidLoad
{
    UIBarButtonItem *problemButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ExclamationMark.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(reportProblem:)];
    self.navigationItem.rightBarButtonItem = problemButton;
    [problemButton release];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.navigationItem.rightBarButtonItem = nil;
    
    [super viewDidUnload];
}

- (void)reportProblem:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Tell owner that the destination is unreachable.  Be specific so they can fix the problem quickly." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Network not available", @"Destination not possible", @"GPS related problem",nil];
    [sheet showInView:self.parentViewController.tabBarController.view];//stackoverflow.com/questions/1197746/uiactionsheet-cancel-button-strange-behaviour
    [sheet release];
}

- (void) actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 3 )
        return;

    [tagService problem:tagKey problemCode:buttonIndex+1 delegate:self didFinish:@selector(didReportProblem:) didFail:@selector(didFail:)];
}

- (void)didReportProblem:(NSDictionary*)dict
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Sent" message:@"Tag owner will be notified of the problem and it should be fixed soon." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release]; 
}

- (void)didFail:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Operation Failed" message:@"Try again or contact support." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release]; 
}
@end
