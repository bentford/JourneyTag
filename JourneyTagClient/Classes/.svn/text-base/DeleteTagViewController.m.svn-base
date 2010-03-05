//
//  DeleteTagViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DeleteTagViewController.h"

@implementation DeleteTagViewController

- (id)initWithTagKey:(NSString*)tagKey target:(id)target action:(SEL)action
{
    self = [super init];
    self.title = @"Delete Tag";
    
    myTagKey = [tagKey retain];
    myTarget = [target retain];
    myAction = action;
    
    tagService = [[JTTagService alloc] init];
    
    return self;
}

- (IBAction) deleteTag:(id)sender
{
    if( [verifyText.text compare:@"YES"] != NSOrderedSame )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Confirmation" message:@"Type the word YES to delete this tag" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release]; 
        return;
    }
    [tagService delete:myTagKey delegate:self didFinish:@selector(didDeleteTag:) didFail:@selector(didFail:)];
}

- (void)didDeleteTag:(NSDictionary*)dict
{
    BOOL success = [(NSString*)[dict objectForKey:@"tagKey"] length] > 0;
    NSNumber *result = [[NSNumber alloc] initWithBool:success];
    if( myTarget && myAction && [myTarget respondsToSelector:myAction] )
        [myTarget performSelectorOnMainThread:myAction withObject:result waitUntilDone:[NSThread isMainThread]];
    
    [result release];
    [self.navigationController popViewControllerAnimated:YES];    
}

- (void)didFail:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Operation Failed" message:@"Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release]; 
}

- (void)dealloc 
{    
    [myTagKey release];
    [myTarget release];
    [super dealloc];
}
@end
