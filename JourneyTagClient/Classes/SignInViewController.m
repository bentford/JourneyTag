//
//  SignInViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SignInViewController.h"
#import "NewAccountViewController.h"
#import "PasswordResetViewController.h"
#import "NetworkUtil.h"

@implementation SignInViewController
- (id)init
{
    self = [super init];
    accountService = [[JTAccountService alloc] init];    
    return self;
}

- (void)viewDidLoad 
{
    self.title = @"Sign In";
    myScrollView.contentSize = CGSizeMake(320, 600);
    
    UIBarButtonItem *newAccountButton = [[UIBarButtonItem alloc] initWithTitle:@"New Account" style:UIBarButtonItemStyleBordered target:self action:@selector(newAccount:)];
    self.navigationItem.rightBarButtonItem = newAccountButton;
    [newAccountButton release];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.title = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    //deprecated
    //need to hide keyboard
    if( textField == username )
    {
        [password becomeFirstResponder];
        [myScrollView scrollRectToVisible:password.frame animated:YES];
        return NO;
    }
    if( textField == password )
    {
        [self signIn:textField];
        return NO;
    }
    return YES;
}

#pragma mark Actions

- (IBAction) forgotPassword:(id)sender
{
    PasswordResetViewController *childController = [[PasswordResetViewController alloc] init];
    [self.navigationController pushViewController:childController animated:YES];
    [childController release];
}

- (IBAction) signIn:(id)sender
{
    if( signingIn )
        return;
    
    signingIn = YES;
    
    [NetworkUtil checkForNetwork];
    [accountService login:[[UIDevice currentDevice] uniqueIdentifier] username:username.text password:password.text delegate:self didFinish:@selector(didSignIn:) didFail:@selector(didFail:)];
}

- (void) newAccount:(id)sender
{
    NewAccountViewController *controller = [[NewAccountViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void) didSignIn:(NSDictionary*)dict
{
    if( [(NSString*)[dict objectForKey:@"accountKey"] compare:@"NotFound"] == NSOrderedSame )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login failed" message:@"Incorrect username or password" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
        [alertView show];
        [alertView release];    
    } else if( [(NSString*)[dict objectForKey:@"accountKey"] compare:@"WrongPhone"] == NSOrderedSame )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wrong Phone" message:@"That account was created on another phone. You can transfer your account but you will need access to the original phone.  Contact support for more information. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];        
    } else {
         [self.parentViewController dismissModalViewControllerAnimated:YES];   
    }
    signingIn = NO;
}

- (void) didFail:(JTServiceHttpRequest*)request
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error signing in.  Please contact support." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];      
    
    signingIn = NO;
}

- (IBAction) closeKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview

}

- (IBAction) goBack:(id)sender
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [accountService release];
    
    [super dealloc];
}


@end
