//
//  JTInventoryService.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTServiceBase.h"

@interface JTInventoryService : JTServiceBase {

}
- (void) get:(NSString*)accountKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) delete:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) create:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
@end
