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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [username resignFirstResponder];
    [email resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [username resignFirstResponder];
    [email resignFirstResponder]; 
    
    return YES;
}

- (void)dealloc {
    [accountService cancelReadRequests];
    [accountService release];
    [super dealloc];
}

@end
