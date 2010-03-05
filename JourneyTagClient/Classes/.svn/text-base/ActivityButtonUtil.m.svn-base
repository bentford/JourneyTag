//
//  ActivityButtonUtil.m
//  JourneyTag1
//
//  Created by Ben Ford on 5/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ActivityButtonUtil.h"


@implementation ActivityButtonUtil
+ (UIBarButtonItem*) createActivityIndicatorButton
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ActivityBackground.png"]];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.frame = CGRectMake(5, 5, 20, 20);
    
    [imageView addSubview:activity];
    [activity release];
    
    [activity startAnimating];
    
    UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithCustomView:imageView] autorelease];    
    [imageView release];
    
    return button;
}

+ (UIBarButtonItem*) createRefreshButton:(id) target action: (SEL) action
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:target action:action];
    [button autorelease];
    return button;
}

+ (UIBarButtonItem*) createWithLabel:(NSString*)label target:(id) target action:(SEL) action
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:label style:UIBarButtonItemStyleBordered target:target action:action];
    [button autorelease];
    return button;    
}
@end
