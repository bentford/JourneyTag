//
//  NewTagController2.h
//  JourneyTag
//
//  Created by Ben Ford on 6/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JTTagService.h"

@interface NewTagViewController2 : UITableViewController 
<UITableViewDataSource, MKReverseGeocoderDelegate, UIActionSheetDelegate>
{
    NSMutableArray *sectionTitles;
    NSMutableArray *sectionLabels;
    
    MKReverseGeocoder *geoCoder;
    BOOL hasDestinationCoordinate;
    CLLocationCoordinate2D destinationCoordinate;
    JTTagService *tagService;
    
    NSArray *accuracyList;
    NSArray *accuracyValues;
    NSString *accuracyBlurb;
    
    NSString *existingName;
    NSString *existingTagKey;
    CLLocationCoordinate2D existingDestinationCoordinate;
    BOOL editExistingTag;
    
    id myDelegate;
    SEL myDidFinish;
    
    BOOL didDeleteTag;
}
- (id)init;
- (id)initWithTagKey:(NSString*)tagKey name:(NSString*)name destinationCoordinate:(CLLocationCoordinate2D)_destinationCoordinate accuracyInMeters:(int)accuracyInMeters delegate:(id)delegate didFinish:(SEL)didFinish;
- (void)setup;

- (void)didEnterName:(NSDictionary*)dict;
- (void) SetDestinationCoordinate:(NSNotification*)notification;
- (void)setDestinationCoordinateWorker:(float)lat lon:(float)lon;

- (void) createTag:(id)sender;

- (void)deleteTag:(id)sender;
- (void)didDeleteTag:(NSNumber*)result;

- (void)showHelp:(id)sender;
@end
