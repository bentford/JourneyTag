//
//  NewAccountViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTAccountService.h"

@interface NewAccountViewController : UIViewController 
<UITextFieldDelegate>
{
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UITextField *password2;
    IBOutlet UITextField *email;
    
    JTAccountService *accountService;
    
    BOOL creatingAccount;
}

- (IBAction) createAccount:(id)sender;
- (IBAction) showPrivacyPolicy:(id)sender;

- (void) didFailSignIn:(NSDictionary*)dict;
- (void) didSignIn:(NSDictionary*)dict;

- (void)trimAllLoginText;
- (BOOL)validPasswordLength;
- (BOOL) passwordIdentical;
- (BOOL)validUsernameLength;
@end
