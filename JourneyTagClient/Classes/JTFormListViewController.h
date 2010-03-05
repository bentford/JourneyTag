//
//  JTFormListViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 8/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JTFormListViewController : UIViewController 
<UIPickerViewDelegate,UIPickerViewDataSource>{
    IBOutlet UILabel *formLabel;
    IBOutlet UIPickerView *pickerView;
    IBOutlet UITextView *detailLabel;
    
    NSString *myLabelText;
    NSString *myDetailText;
    NSArray *myListValues;
    NSString *myDefaultValue;
    
    NSString *selectedText;

    
    id myDelegate;
    SEL mySelector;    
}

- (id)initWithLabelText:(NSString*)labelText detailText:(NSString*)detailText listValues:(NSArray*)listValues defaultValue:(NSString*)defaultValue delegate:(id)delegate didChooseValueSelector:(SEL)didChooseValueSelector;
- (void)saveValue:(id)sender;
@end
