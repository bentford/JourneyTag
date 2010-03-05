//
//  PickupTagDetailsTableViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 6/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PickupTagDetailsTableViewController.h"

#define kMessageViewTag 6
#define MOVE_ANIMATION_DURATION_SECONDS 0.5

@implementation PickupTagDetailsTableViewController

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];    
    if( withinPickupRange && hasLocation)
    {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Pickup Tag" style:UIBarButtonItemStylePlain target:self action:@selector(confirmTagPickup)];
        self.navigationItem.rightBarButtonItem = button;
        [button release];
    }
    
    if( !withinPickupRange )
    {
        UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, -45, 320, 45)];
        messageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UIImageView *bar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AnimatedBarOrange.png"]];
        bar.frame = CGRectMake(10, 0, 300, 45);
        
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(20, -3, 280, 45)];
        text.text = @"Tag is out of range.  It must be 5 miles or closer to pickup.";
        text.backgroundColor = [UIColor clearColor];
        text.editable = NO;
        text.scrollEnabled = NO;
        text.font = [UIFont boldSystemFontOfSize:14.0];
        text.textAlignment = UITextAlignmentCenter;
        
        [messageView addSubview:bar];
        [messageView addSubview:text];
        [self.view addSubview:messageView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:MOVE_ANIMATION_DURATION_SECONDS];
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 45);
        messageView.transform = transform;
        self.tableView.transform = transform;
        
        [UIView commitAnimations];
        
        [bar release];
        [text release];
        [messageView release];
    }
}

- (void)viewDidUnload
{
    [[self.view viewWithTag:kMessageViewTag] removeFromSuperview];    
}
@end
