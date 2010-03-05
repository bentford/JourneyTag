//
//  DepotTableViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 5/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTDepotService.h"
#import <MapKit/MapKit.h>

@interface DepotTableViewController : UITableViewController
<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,MKReverseGeocoderDelegate>{
    NSMutableArray *list;
    NSMutableArray *keyList;
    NSMutableArray *statusList;
    NSMutableArray *locationNoteList;
    NSMutableArray *depotList;
    
    int currentLocationNoteIndex;
    MKReverseGeocoder *geocoder;
    
    NSInteger selectedDepot;
    JTDepotService *depotService;
    NSString *myTagKey;
    
    NSArray *statusLabels;

    id myTarget;
    SEL myDidChooseDepotSelector;
    
    BOOL isLoading;
}
- (id)initWithTagKey:(NSString*)tagKey target:(id)target action:(SEL)didChooseDepot;
- (void) didGetDepots:(NSDictionary*)dict;
- (void) didFail:(id)sender;
- (void)loadLocationNote;
@end
