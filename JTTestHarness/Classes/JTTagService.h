//
//  JTTagService.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTServiceBase.h"

@interface JTTagService : JTServiceBase {

}
- (void) getAllForYourAccount: (id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) create:(NSString*)name destLat:(double) destLat destLon:(double)destLon destinationAccuracy:(int)destinationAccuracy delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void)delete:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) updateTagWithKey:(NSString*) tagKey name:(NSString*)name destLat:(float)destLat destLon:(float)destLon destinationAccuracy:(int)destinationAccuracy delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) drop:(NSString*)tagKey imageData:(NSData*)imageData lat:(double)lat lon:(double)lon delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) dropAndPickup:(NSString*)tagKey imageData:(NSData*)imageData lat:(double)lat lon:(double)lon delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) dropAtDepot:(NSString*)tagKey depotKey:(NSString*)depotKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) pickup:(NSString*) tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) getForCoordinate:(double)viewLat viewLon:(double)viewLon physicalLat:(double)physicalLat physicalLon:(double)physicalLon  delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) get:(NSString*)tagKey  delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void)problem:(NSString*)tagKey problemCode:(int)problemCode delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
@end
