//
//  JTMarkService.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTServiceBase.h"

@interface JTMarkService : JTServiceBase {

}
- (void) create:(NSString*)tagKey photoKey:(NSString*)photoKey lat:(double)lat lon:(double)lon delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) getAllForTag:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;

@end
