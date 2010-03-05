//
//  NewTagDetailViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewTagDetailViewController : UIViewController {
    IBOutlet UILabel *itemLabel;
    IBOutlet UITextField *textField;
    
    NSString *myLabelText;
    NSString *myValueText;
    
    id myDelegate;
    SEL mySelector;

}

- (id)initWithLabelText:(NSString*)labelText valueText:(NSString*)valueText delegate:(id)delegate didEnterNameSelector:(SEL)didEnterNameSelector;
- (void) saveValue:(id)sender;
@end
