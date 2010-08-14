//
//  AdvertisementViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 8/14/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHideAdDuration 0.5

@protocol HideAdHelperDelegate
- (UIView *)mainView;
- (UIView *)bannerView;
@optional
- (UIView *)slideDownView;
@end

@interface HideAdHelper : NSObject {
    NSObject<HideAdHelperDelegate> *delegate;
    
    BOOL isVisible;
}

@property (nonatomic, assign) NSObject<HideAdHelperDelegate> *delegate;

- (void)hideBannerView;
@end
