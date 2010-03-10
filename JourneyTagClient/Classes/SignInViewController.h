//
//  SignInViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTServiceHttpRequest.h"
#import "JTAccountService.h"

@interface SignInViewController : UIViewController 
<UITextFieldDelegate>
{
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    
    JTAccountService *accountService;
    
    IBOutlet UIScrollView *myScrollView;
    
    BOOL signingIn;
}

- (IBAction) closeKeyboard:(id)sender;
- (IBAction) goBack:(id)sender;

- (void) newAccount:(id)sender;
- (IBAction) signIn:(id)sender;

- (IBAction) forgotPassword:(id)sender;

- (void) didSignIn:(NSDictionary*)dict;
- (void) didFail:(JTServiceHttpRequest*)request;
@end
