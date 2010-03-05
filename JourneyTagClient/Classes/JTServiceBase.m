//
//  JTServiceBase.m
//  JourneyTag
//
//  Created by Ben Ford on 6/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTServiceBase.h"

@implementation JTServiceBase

- (id) init
{
    self = [super init];
    if ( self != nil )
    {
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void) cancelAllRequests
{
    [queue cancelAllOperations];
}

- (void)dealloc
{
    [queue cancelAllOperations];
    [queue release];
    [super dealloc];
}
@end
