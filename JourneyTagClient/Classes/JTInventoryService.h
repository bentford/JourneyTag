//
//  JTInventoryService.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTServiceBase2.h"

@interface JTInventoryService : JTServiceBase2 {

}
- (void) get:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) delete:(NSString*)inventoryKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) create:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
@end
