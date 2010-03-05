/**
 *  ARRollerView.h
 *  
 *  Copyright 2009 AdWhirl Inc. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

@class ARRollerController, ARRollerViewInternal;
@protocol ARRollerDelegate;

@interface ARRollerView : UIView

/** 
 * Call this method to get a view object that you can add to your own view. You must also provide a delegate.  
 * The delegate provides AdWhirl's application key and can listen for important messages.  
 * You can configure the roller's settings and specific ad network information on AdWhirl.com.  
 */
+ (ARRollerView*)requestRollerViewWithDelegate:(id<ARRollerDelegate>)delegate;

/**
 * Call this method as early as you can, typically in your applicationDidFinishLaunching application delegate method
 * to force the roller to fetch configuration data immediately.  Although the ad requests to ad networks themselves will incur 
 * much much more overhead than downloading configuration data from AdWhirl, this method should entirely remove the round-trip delay overhead.
 * This would save you the round-trip delay to the server when you create your first roller, since the configuration should be
 * downloaded before you attempt to instantiate a roller.  Subsequent roller instances (with respect to the same application key)
 * do not incur a round-trip delay since configuration data is only fetched once per app session.
 */
+ (void)startPreFetchingConfigurationDataWithDelegate:(id<ARRollerDelegate>)delegate;

/**
 * Call this method to get another ad to display. 
 * You can also specify under "app settings" on AdWhirl.com to automatically get new ads periodically 
 * (30 seconds, 45 seconds, 1 min, etc.), as well as these options:
 *   - change the animation between ad transitions.
 *   - change the text color.
 *   - change the background color.
 *   - change location request access on or off.
 */
- (void)getNextAd;

/**
 * Call this method if you prefer a rollover instead of a getNextAd call.  This is offered primarily for developers
 * who want to use generic notifications and then execute a rollover when an ad network fails to serve an ad.
 */
- (void)rollOver;

/**
 * The delegate is informed asynchronously whether an ad succeeds or fails to load.  
 * If you prefer to poll for this information, you can do so.
 *
 */
- (BOOL)adExists;

/**
 * Call this method to get the name of the most recent ad network that an ad request was made to.
 */
- (NSString*)mostRecentNetworkName;

/**
 * Call this method to ignore the automatic refresh timer. 
 * 
 * Note that the refresh timer is NOT invalidated when you call ignoreAutoRefreshTimer.  This will simply ignore the refresh events that are called
 * by the automatic refresh timer (if the refresh timer is enabled via AdWhirl.com).  So, for example, let's say you have a refresh cycle of
 * 60 seconds.  If you call ignoreAutoRefreshTimer at 30 seconds, and call resumeRefreshTimer at 90 sec, then the first
 * refresh event is ignored, but the second refresh event at 120 sec will run.
 */
-(void)ignoreAutoRefreshTimer;
-(void)doNotIgnoreAutoRefreshTimer;

/**
 * Call this method to ignore automatic refreshes AND manual refreshes entirely.  
 *
 * This is provided for developers who asked to disable refreshing entirely, whether automatic or manual.
 * If you call ignoreNewAdRequests, the roller will:
 * 1) Ignore any Automatic refresh events (via the refresh timer) AND
 * 2) Ignore any manual refresh calls (via getNextAd and rollOver)
 * whether they are run automatically (via the refresh timer) or manually (via calls to getNextAd and rollOver).
 */
-(void)ignoreNewAdRequests;
-(void)doNotIgnoreNewAdRequests;

/**
 * Call this method to replace the roller view with your own view
 */
-(void)replaceBannerViewWith:(UIView*)bannerView;
#pragma mark Deprecated methods
-(void)replaceBannerView:(UIView*)bannerView; //Please use replaceBannerViewWith, instead
#pragma mark Deprecated methods

/**
 * This is mainly offered so that when your delegate is dealloced you can set the roller's delegate to nil 
 * so that messages from the roller aren't sent to a dangling pointer.
 */
- (void)setDelegateToNil;
@end
