//
//  PasswordReminderViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 7/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PasswordResetViewController.h"

@implementation PasswordResetViewController

- (id) init
{
    self = [super init];
    self.title = @"Reset Password";
    accountService =  [[JTAccountService alloc] init];
    
    return self;
}

- (void)viewDidLoad
{    
    myScrollView.contentSize = CGSizeMake(320, 600);
    [super viewDidLoad];
}

- (IBAction)resetPassword:(id)sender
{
    [accountService resetPassword:[[UIDevice currentDevice] uniqueIdentifier] username:username.text email:email.text delegate:self didFinish:@selector(didResetPassword:) didFail:@selector(didFail:)];
}

- (void)didResetPassword:(NSDictionary*)dict
{
    if( [(NSString*)[dict objectForKey:@"response"] compare:@"Match"] == NSOrderedSame )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Sent" message:@"...but it may take a few minutes." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Match" message:@"That username and email were not created on this phone.  Each account is tied to a specific phone and can only be moved by request." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    myScrollView.frame = CGRectMake(0, 0, 320, 190);   
    myScrollView.contentSize = CGSizeMake(320, 300);
    logo.frame = CGRectMake(0, 7, 320, 85);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == username )
    {
        [email becomeFirstResponder];
        [myScrollView scrollRectToVisible:button.frame animated:YES];
        return NO;
    }
    if( textField == email )
    {
        [self resetPassword:textField];
        [textField resignFirstResponder];
        [self adjustViewSizeBack];
        return YES;
    }
    return YES;
}

- (void)adjustViewSizeBack
{
    myScrollView.frame = CGRectMake(0, 0, 320, 417);   
    myScrollView.contentSize = CGSizeMake(320, 500);
    logo.frame = CGRectMake(0, 7, 320, 85);
}

- (void)dealloc {
    [accountService cancelReadRequests];
    [accountService release];
    [super dealloc];
}


@end
