//
//  TransferAccountViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 8/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TransferAccountViewController.h"


@implementation TransferAccountViewController

- (id)init
{
    self = [super init];
    accountService = [[JTAccountService alloc] init];    
    return self;
}

- (void)viewDidLoad 
{
    self.title = @"Transfer Account";
    myScrollView.contentSize = CGSizeMake(320, 600);

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.title = nil;
    [super viewDidUnload];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    myScrollView.frame = CGRectMake(0, 0, 320, 190);   
    logo.frame = CGRectMake(0, 20, 320, 85);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == username )
    {
        [password becomeFirstResponder];
        [myScrollView scrollRectToVisible:password.frame animated:YES];
        return NO;
    } else if( textField == password )
    {
        [email becomeFirstResponder];
        [myScrollView scrollRectToVisible:email.frame animated:YES];
        return NO;
    } else if( textField == email )
    {
        [transferCode becomeFirstResponder];
        [myScrollView scrollRectToVisible:transferCode.frame animated:YES];
        return NO;
    } else if ( textField == transferCode )
    {
        myScrollView.frame = CGRectMake(0, 0, 320, 453);    
        [transferCode resignFirstResponder];
        logo.frame = CGRectMake(0, 20, 320, 85);
        [myScrollView scrollRectToVisible:logo.frame animated:YES];

        return YES;
    }
    return YES;
}

- (IBAction) transferAccountPressed:(id) sender
{
    [accountService transferAccountWithUsername:username.text password:password.text email:email.text uuid:[[UIDevice currentDevice] uniqueIdentifier] token:transferCode.text delegate:self didFinish:@selector(didTransfer:) didFail:@selector(didFail:)];
}

- (void)didTransfer:(NSDictionary*)dict
{
    NSString *title;
    NSString *message;
    NSString *response = [dict objectForKey:@"response"];
    if( [response compare:@"PreviousDevice"] == NSOrderedSame )
    {
        title = @"Previous Device";
        message = @"This account has existed on this device in the past and the transfer is a one-time-operation..  Contact support for further help.";
    } else if( [response compare:@"AccessDenied"] == NSOrderedSame )
    {
        title = @"Login Failed";
        message = @"Make sure you entered correct username, password, and email. Contact support for further help. ";
    } else if( [response compare:@"failed"] == NSOrderedSame )
    {
        title = @"Code Failed";
        message = @"Transfer code was incorrect or expired.  Type your code exactly as it appears in your email.   Also try requesting a new code or contact support for further help.";
    } else {
        title = @"Success";
        message = @"You may now login to your account on this device.";        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release]; 
}

- (void)dealloc {
    [accountService cancelReadRequests];
    [accountService release];
    [super dealloc];
}


@end
