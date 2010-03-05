//
//  DepotIndexTableViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTDepotService.h"
#import <MapKit/MapKit.h>

@interface DepotIndexTableViewController : UITableViewController 
<UITableViewDelegate, UITableViewDataSource,MKReverseGeocoderDelegate>{
    NSMutableArray *list;
    NSMutableArray *locationNoteList;
    NSMutableArray *depotList;
    
    JTDepotService *depotService;
    
    int currentLocationNoteIndex;
    MKReverseGeocoder *geocoder;

    id myDelegate;
    SEL myDidSelectDepotSelector;
}
- (id)initWithDelegate:(id)delegate didSelectDepot:(SEL)didSelectDepotSelector;
- (void) didFail:(id)sender;
- (void) didGetDepots:(NSDictionary*)dict;
- (void) loadLocationNote;
@end
