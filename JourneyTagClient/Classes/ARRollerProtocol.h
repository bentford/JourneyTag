/**
 *  ARRollerProtocol.h
 *  
 *  Copyright 2009 AdWhirl Inc. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

@class CLLocation, ARRollerView;
@protocol ARRollerDelegate<NSObject>

@required
/**
 * Return the AdWhirl application key that you created for your application on AdWhirl.com.  This is REQUIRED, and is the only required method.
 */
- (NSString*)adWhirlApplicationKey; //e.g. The AdWhirl application key that you retrieved from the developer section: http://www.AdWhirl.com/
@optional

#pragma mark Deprecated
- (NSString*)adRolloApplicationKey; //This delegate method is an alias for adWhirlApplicationKey (for developers who used an earlier version of AdWhirl).  e.g. The AdWhirl application key that you retrieved from the developer section: http://www.AdWhirl.com/
#pragma mark Deprecated

/**
 * You can listen to callbacks from AdWhirl via these methods.  When AdWhirl is notified that an ad request is fulfilled, it will notify you immediately.
 * Thus, when notified that an ad request succeeded, you can choose to add the ARRollerView object as a subview to your view.  This view contains the ad.
 * When you are notified that an ad request failed, you are also informed if the AdWhirl is fetching a backup ad.
 * The backup fetching order is specified by you on AdWhirl.com.  When all backup sources are attempted and the last ad request still fails,
 * the usingBackup parameter will be set to NO.  You can use this notification to try again and perhaps request another roller via [ARRollerView requestRollerViewWithDelegate:]
 */
- (void)rollerDidReceiveAd:(ARRollerView*)adWhirlView;
- (void)rollerDidFailToReceiveAd:(ARRollerView*)adWhirlView usingBackup:(BOOL)YesOrNo;

/**
 * You can control when this notification occurs via the developers member section.  You can allocate a percentage of your ad 
 * requests to initiate this callback.  When you receive this notification, you can execute any code block that you own.
 * For example, you can remove the roller view after getting this callback.
 * Or you can make an ad request from a specific ad network that is not integrated into AdWhirl via their SDK library.
 * After the ad request from the "generic" ad network succeeds, you can then attach their view as a subview, and then remove
 * the roller's view.  And vice versa, when a refresh cycle kicks in, you can listen on didReceiveAd to detect that 
 * the roller received a new ad and put the roller's view back up and remove the "generic" ad's view.
 */
- (void)rollerReceivedRequestForDeveloperToFulfill:(ARRollerView*)adWhirlView; 

/**
 * As requested by several developers, in the event that ads are OFF, you can listen to this callback method to determine that ads have been turned off.
 */
- (void)rollerReceivedNotificationAdsAreOff:(ARRollerView*)adWhirlView;

/**
 * These notifications will let you know when a user is being shown a full screen webview canvas with an ad because they tapped on an ad.  You should listen to these notifications
 * to determine when to pause/resume your game--if you're building a game app.
 */
- (void)willDisplayWebViewCanvas;
- (void)didDismissWebViewCanvas;

/**
 * You can optionally hardcode your application keys for each ad network by returning application keys for these methods.  
 * We don't recommend this, however, because you can dynamically change your application keys on AdWhirl.com.
 * This option is offered to you but note that once you implement these methods, AdWhirl will never override your values.
 * Therefore, IF you implement these methods, you will NOT have the flexibility to change them on the fly via AdWhirl.com--so MAKE SURE the app keys are correct.  You have been warned!
 *
 */
- (NSDictionary*)quattroWirelessDictionary;  //e.g. Key-value pairs for the keys "publisherID" and "siteID" provided by Quattro Wireless.  Set NSString values for these two keys.
- (NSString*)pinchApplicationKey; //e.g. Your Application Code from Pinch Media
- (NSDictionary*)videoEggConfigDictionary;  //e.g. Key-value pairs for the keys "publisher" and "area" information from Video Egg.  Set NSString values for these two keys.  Refer to the AdWhirl sample code to see a sample dictionary.
- (NSString*)millennialMediaApIDString;  //e.g. The ApID string from Millennial Media.  Return an NSString object.

/**
 * Try to return as much info about the user as you can.  This information is fed to ad networks that are open to this kind of information (Quattro Wireless).  
 */
- (CLLocation*)locationInfo;
- (NSString*)postalCode; 
- (NSString*)areaCode; 
- (NSDate*)dateOfBirth; 
- (NSString*)gender; 
- (NSString*)searchString; 
- (NSString*)keywords; 
- (NSUInteger)incomeLevel;


/**
 * You can configure these options on www.AdWhirl.com dynamically, on-the-fly. 
 * You can turn on/off the location request, which in turn activates/deactivates the "Allow Location" prompt.
 * If you switch on location access, the location information is then relayed to ad networks that are open to this information (Quattro Wireless).
 */
//- (BOOL)canRequestLocation;
//- (UIColor *)embeddedWebViewTintColor;  


/**
 * If you implement these methods, then the UIColor instances that you provide will be used.
 * Otherwise, if you choose NOT to implement these options, then you can drive the colors on-the-fly via www.AdWhirl.com
 * You can also configure these options via www.AdWhirl.com
 */
- (UIColor*)backgroundColor;
- (UIColor*)textColor;

#pragma mark QuattroWireless-specific optional delegate methods
/**
 * Return a value for the education level if you have access to this info.  This information will be relayed to Quattro Wireless if provided.
 * QWEducationNoCollege = 0
 * QWEducationCollegeGraduate = 1
 * QWEducationGraduateSchool = 2
 * QWEducationUnknown = 3
 */
- (NSUInteger)quattroWirelessEducationLevel;

#pragma mark MillennialMedia-specific optional delegate methods
/** 
 * Return a value for the education level if you have access to this info.  This information will be relayed to Millennial Media if provided
 * MMEducationUnknown = 0,
 * MMEducationHishSchool = 1,
 * MMEducationSomeCollege = 2,
 * MMEducationInCollege = 3,
 * MMEducationBachelorsDegree = 4,
 * MMEducationMastersDegree = 5,
 * MMEducationPhD = 6
 */
- (NSUInteger)millennialMediaEducationLevel;

/** 
 * Return a value for ethnicity if you have access to this info.  This information will be relayed to Millennial Media if provided.
 * MMEthnicityUnknown = 0,
 * MMEthnicityAfricanAmerican = 1,
 * MMEthnicityAsian = 2,
 * MMEthnicityCaucasian = 3,
 * MMEthnicityHispanic = 4,
 * MMEthnicityNativeAmerican = 5,
 * MMEthnicityMixed = 6
 */
- (NSUInteger)millennialMediaEthnicity;

/**
 * Return a value for the user's age if you have access to this info
 */
- (NSUInteger)millennialMediaAge;

@end
