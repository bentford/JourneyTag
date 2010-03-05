//
//  JTFormListViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 8/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTFormListViewController.h"


@implementation JTFormListViewController

- (id)initWithLabelText:(NSString*)labelText detailText:(NSString*)detailText listValues:(NSArray*)listValues defaultValue:(NSString*)defaultValue delegate:(id)delegate didChooseValueSelector:(SEL)didChooseValueSelector;
{
    self = [super init];
    myLabelText = [labelText retain];
    myDetailText = [detailText retain];
    myListValues = [listValues retain];
    myDefaultValue = [defaultValue retain];
    
    selectedText = [myListValues objectAtIndex:0];

    
    
    myDelegate = [delegate retain];
    mySelector = didChooseValueSelector;
    return self;
}

- (void)viewDidLoad 
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveValue:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    formLabel.text = myLabelText;
    detailLabel.text = myDetailText;

    int row = [myListValues indexOfObject:myDefaultValue];
    [pickerView selectRow:row inComponent:0 animated:NO];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.navigationItem.rightBarButtonItem = nil;
    
    [super viewDidUnload];
}

- (void) saveValue:(id)sender
{
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:selectedText,@"value",myLabelText,@"label",nil];
    
    if (mySelector && myDelegate && [myDelegate respondsToSelector:mySelector]) 
    {
        [myDelegate performSelectorOnMainThread:mySelector withObject:data waitUntilDone:[NSThread isMainThread]];
    }
    [data release];   
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [myListValues count];
}

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [myListValues objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedText = [myListValues objectAtIndex:row];
}

- (void)dealloc 
{
    [myLabelText release];
    [myDetailText release];
    [myListValues release];
    [myDefaultValue release];
    [selectedText release];
    
    [myDelegate release];
    
    [super dealloc];
}

@end
