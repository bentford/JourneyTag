//
//  JTServiceBase.h
//  JTTestHarness1
//
//  Created by Ben Ford on 6/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface JTServiceBase : NSObject {
    NSOperationQueue *queue;
}

- (id) init;
- (void) cancelAllRequests;

@end
