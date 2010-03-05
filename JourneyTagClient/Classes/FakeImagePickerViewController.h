//
//  FakeImagePickerViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 8/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FakeImagePickerViewController : UIViewController {
    id myDelegate;
    SEL mySelector;
    NSMutableArray *bigData;
}

- (id) initWithDelegate:(id)delegate selector:(SEL)selector;
- (IBAction)didTakeFakePhoto:(id)sender;

@end
