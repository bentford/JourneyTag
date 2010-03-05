//
//  JTServiceBase2.h
//  JourneyTag
//
//  Created by Ben Ford on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface JTServiceBase2 : NSObject {
    NSOperationQueue *readQueue;
    NSOperationQueue *writeQueue;
}
//- (id)initWithWriteQueue:(NSOperationQueue*)queue;
- (id)init;
- (void) cancelReadRequests;
@end
