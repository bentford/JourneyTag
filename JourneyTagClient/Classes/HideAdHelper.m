//
//  AdvertisementViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 8/14/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import "HideAdHelper.h"


@implementation HideAdHelper
@synthesize delegate;

- (id)init {
    if( self = [super init] ) {
        isVisible = YES;
    }
    return self;
}

- (void)hideBannerView {
    
    if( isVisible == NO )
        return;
    
    isVisible = NO;
    
    [UIView animateWithDuration:kHideAdDuration animations:^{
        CGRect frame = [delegate bannerView].frame;
        frame.origin.y += [delegate bannerView].frame.origin.y;
        [delegate bannerView].frame = frame;
        
        frame = [delegate mainView].frame;
        frame.size.height += [delegate bannerView].frame.size.height;
        [delegate mainView].frame = frame;
        
        if( delegate && [delegate respondsToSelector:@selector(slideDownView)] ) {
            frame = [delegate slideDownView].frame;
            frame.origin.y += [delegate bannerView].frame.size.height;
            [delegate slideDownView].frame = frame;
        }
        
    }];
}

- (void)dealloc {
    self.delegate = nil;
    
    [super dealloc];
}
@end
