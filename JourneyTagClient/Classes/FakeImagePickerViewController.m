//
//  FakeImagePickerViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 8/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FakeImagePickerViewController.h"


@implementation FakeImagePickerViewController

- (id) initWithDelegate:(id)delegate selector:(SEL)selector
{
    self = [super init];
    myDelegate = [delegate retain];
    mySelector = selector;
    bigData = [[NSMutableArray alloc] initWithCapacity:5000];
    for( int i = 0; i < 5000; i++)
        [bigData addObject:[NSNumber numberWithInt:i]];
    return self;
}

- (IBAction)didTakeFakePhoto:(id)sender
{
    if (mySelector && myDelegate && [myDelegate respondsToSelector:mySelector]) 
    {
        [myDelegate performSelectorOnMainThread:mySelector withObject:nil waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)dealloc 
{
    [myDelegate release];
    [bigData release];
            
    [super dealloc];
}


@end
