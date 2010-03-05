//
//  AccountSettingsViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 8/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "JTEmailUtil.h"

@implementation AccountSettingsViewController

- (id)init
{
    self = [super init];
    accountService = [[JTAccountService alloc] init];
    return self;
}

-(void)viewDidLoad
{
    self.title = @"Account Settings";

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.title = nil;
    [super viewDidUnload];
}

- (IBAction)changePassword:(id)sender
{
    newPassword.text = [newPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if( [newPassword.text length] >= 5 )
    {
        [accountService changePassword:newPassword.text delegate:self didFinish:@selector(didChangePassword:) didFail:@selector(didFail:)];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too short" message:@"Passwords need to be at least 5 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];       
    }
}

- (void) didChangePassword:(NSDictionary*)dict
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Changed" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];    
}

- (IBAction)changeEmail:(id)sender
{
    newEmail.text = [newEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if( [JTEmailUtil validateEmail:newEmail.text] ) 
    {
        [accountService changeEmail:newEmail.text delegate:self didFinish:@selector(didChangeEmail:) didFail:@selector(didFail:)];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email Address" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];       
    }
}

- (void)didChangeEmail:(NSDictionary*)dict
{
    if( [(NSString*)[dict objectForKey:@"response"] compare:@"success"] == NSOrderedSame )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Changed" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];    
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:[dict objectForKey:@"reason"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];    
    }
}

- (void) didFail:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Network or server error." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];       
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)accountTransfer:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Request Transfer?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Email Transfer Code",@"Cancel",nil];
    sheet.destructiveButtonIndex = 0;
    [sheet showInView:self.view];
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 )
    {
        [accountService requestTransferCode:self didFinish:@selector(didRequestTransferCode:) didFail:@selector(didFail:)];
    }
}

- (void)didRequestTransferCode:(NSDictionary*)dict
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Sent" message:@"A code and some instructions were sent to your email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];   
}

- (void)dealloc {
    [accountService cancelReadRequests];
    [accountService release];
    
    [super dealloc];
}


@end
