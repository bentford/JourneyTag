/**
 * AdMobDelegateProtocol.h
 * AdMob iPhone SDK publisher code.
 *
 * Defines the AdMobDelegate protocol.
 */
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@class AdMobView;

@protocol AdMobDelegate<NSObject>

@required


- (NSString *)publisherId;

@optional

- (void)didReceiveAd:(AdMobView *)adView;
- (void)didFailToReceiveAd:(AdMobView *)adView;
- (UIColor *)adBackgroundColor;
- (UIColor *)primaryTextColor;
- (UIColor *)secondaryTextColor;

- (BOOL)useGraySpinner;
- (BOOL)mayAskForLocation;
- (CLLocation *)location;
- (BOOL)useTestAd;
- (NSString *)testAdAction;



//if not available, return nil.
- (NSString *)postalCode; // user's postal code, e.g. "94401"
- (NSString *)areaCode; // user's area code, e.g. "415"
- (NSDate *)dateOfBirth; // user's date of birth
- (NSString *)gender; // user's gender (e.g. @"m" or @"f")
- (NSString *)keywords; // keywords the user has provided or that are contextually relevant, e.g. @"twitter client iPhone"
- (NSString *)searchString; // a search string the user has provided, e.g. @"Jasmine Tea House San Francisco"

- (UIBarStyle)embeddedWebViewBarStyle;
- (UIColor *)embeddedWebViewTintColor;

- (void)willPresentFullScreenModal;
- (void)didDismissFullScreenModal;

@end