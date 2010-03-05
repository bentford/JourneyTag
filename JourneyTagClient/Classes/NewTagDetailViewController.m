//
//  NewTagDetailViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NewTagDetailViewController.h"


@implementation NewTagDetailViewController

- (id)initWithLabelText:(NSString*)labelText valueText:(NSString*)valueText delegate:(id)delegate didEnterNameSelector:(SEL)didEnterNameSelector
{
    self = [super init];
    myLabelText = [labelText retain];
    myValueText = [valueText retain];
    
    myDelegate = [delegate retain];
    mySelector = didEnterNameSelector;
    return self;
}

- (void)viewDidLoad 
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveValue:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];

    itemLabel.text = myLabelText;
    textField.text = myValueText;
    
    [super viewDidLoad];
}

- (void) saveValue:(id)sender
{
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:textField.text,@"value",myLabelText,@"label",nil];
  
    if (mySelector && myDelegate && [myDelegate respondsToSelector:mySelector]) 
    {
        [myDelegate performSelectorOnMainThread:mySelector withObject:data waitUntilDone:[NSThread isMainThread]];
    }
    [data release];   
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [itemLabel release];
    [textField release];
    [myLabelText release];
    [myValueText release];
    [myDelegate release];
    
    [super dealloc];
}


@end
