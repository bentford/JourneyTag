//
//  JTDepotService.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTServiceBase.h"

@interface JTDepotService : JTServiceBase {

}
- (void) get:(NSString*)depotKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) getAllByStatus:(BOOL) pickedUp delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) getAllAsTargetForTag:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) create:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) drop:(NSString*)depotKey imageData:(NSData*)imageData lat:(double)lat lon:(double)lon delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) pickup:(NSString*)depotKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
@end
