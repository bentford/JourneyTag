//
//  AccountSettingsViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 8/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTAccountService.h"

@interface AccountSettingsViewController : UIViewController 
<UITextFieldDelegate, UIActionSheetDelegate>
{
    IBOutlet UITextField *newEmail;
    IBOutlet UITextField *newPassword;
    JTAccountService *accountService;
}

- (IBAction)changePassword:(id)sender;
- (IBAction)changeEmail:(id)sender;
- (IBAction)accountTransfer:(id)sender;
@end
