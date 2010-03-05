//
//  PasswordReminderViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 7/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTAccountService.h"

@interface PasswordResetViewController : UIViewController 
<UITextFieldDelegate> {
    
    IBOutlet UIScrollView *myScrollView;
    IBOutlet UITextField *username;
    IBOutlet UITextField *email;
    IBOutlet UIButton *button;
    IBOutlet UIImageView *logo;
    
    JTAccountService *accountService;
}

- (IBAction)resetPassword:(id)sender;
- (void)adjustViewSizeBack;
@end
