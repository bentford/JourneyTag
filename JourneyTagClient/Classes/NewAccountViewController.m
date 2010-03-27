//
//  NewAccountViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NewAccountViewController.h"
#import "JTEmailUtil.h"
#import "TransferAccountViewController.h"
#import "HelpViewController.h"
#import "NetworkUtil.h"

@implementation NewAccountViewController

- (id)init
{
    self = [super init];
    accountService = [[JTAccountService alloc] init];    
    creatingAccount = NO;
    return self;
}

- (void)viewDidLoad 
{
    self.title = @"New Account";
    
    UIBarButtonItem *transferButton = [[UIBarButtonItem alloc] initWithTitle:@"Transfer" style:UIBarButtonItemStyleBordered target:self action:@selector(transferButtonPressed:)];
    self.navigationItem.rightBarButtonItem = transferButton;
    [transferButton release];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.navigationItem.rightBarButtonItem = nil;
    
    [super viewDidUnload];
}

- (void)transferButtonPressed:(id)sender
{
    TransferAccountViewController *childController = [[TransferAccountViewController alloc] init];
    [self.navigationController pushViewController:childController animated:YES];
    [childController release];
}

#pragma mark IBActions

- (IBAction) createAccount:(id)sender
{
    [NetworkUtil checkForNetwork];
    
    if( creatingAccount )
        return;

    [self trimAllLoginText];
    
    if( ![self validPasswordLength] )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password too short" message:@"Use 5 characters or more" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
        [alertView show];
        [alertView release];    
        return;
    }
    
    if( ![self validUsernameLength] )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Username too short!" message:@"Use 3 characters or more" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;        
    }
    
    if( ![JTEmailUtil validateEmail:email.text] )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email Address" message:@"" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;                
    }
    creatingAccount = YES;
    [accountService createAccount:[[UIDevice currentDevice] uniqueIdentifier] username:username.text password:password.text email:email.text delegate:self didFinish:@selector(didCreateAccount:) didFail:@selector(didFail:)];

}

#pragma mark ServiceActions
- (void) didCreateAccount:(NSDictionary*)dict
{
    if( [(NSString*)[dict objectForKey:@"accountKey"] compare:@"NotUnique"] == NSOrderedSame )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:@"Username has already been taken" delegate:nil cancelButtonTitle:@"Try Another" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    else {
        [accountService login:[[UIDevice currentDevice] uniqueIdentifier] username:username.text password:password.text delegate:self didFinish:@selector(didSignIn:) didFail:@selector(didFailSignIn:)];
    }
    creatingAccount = NO;
}

- (void) didSignIn:(NSDictionary*)dict
{
       [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void) didFailSignIn:(NSDictionary*)dict
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your account was created, but sign in failed.  Try signing in again." delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [alertView show];
    [alertView release];    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [username resignFirstResponder];
    [password resignFirstResponder];
    [email resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [username resignFirstResponder];
    [password resignFirstResponder];
    [email resignFirstResponder];
}

- (void)trimAllLoginText
{
    username.text = [username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   password.text  = [password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    password2.text = [password2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL) passwordIdentical
{
    return [password.text compare:password2.text] == NSOrderedSame;
}

- (BOOL)validPasswordLength
{
    return [password.text length] >= 5;
}

- (BOOL)validUsernameLength
{
    return [username.text length] >= 3;
}

- (IBAction) showPrivacyPolicy:(id)sender
{
    HelpViewController *privacyController = [[HelpViewController alloc] initWithFile:@"privacy"];
    [self presentModalViewController:privacyController animated:YES];
}

- (void)didFail:(ASIHTTPRequest *)request {
    creatingAccount = NO;
    NSString *message = [request.error localizedDescription];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Oops, something went wrong.  Here is a clue: %@", message] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)dealloc {
    [accountService cancelReadRequests];
    [accountService release];
    [super dealloc];
}


@end
