//
//  DepotDetailsTableViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 5/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTService.h"

@interface DepotDetailsTableViewController : UITableViewController 
<UIActionSheetDelegate>
{
    NSString *myDepotKey;
    NSString *myPhotoKey;
    
    NSArray *list;
    NSArray *labels;
    NSArray *sections;
    
    JTDepotService *depotService;
}
- (id)initWithDepotKey:(NSString*)depotKey;

- (void) pickupDepot;
- (void) refreshData;
- (void) didLoadDepot:(NSDictionary*)dict;
- (void) didFail:(id)sender;
- (void) didPickupDepot:(NSDictionary*)dict;
@end