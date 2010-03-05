//
//  JTServiceBase2.m
//  JourneyTag
//
//  Created by Ben Ford on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTServiceBase2.h"
#import "JTGlobal.h"

@implementation JTServiceBase2

- (id)init
{
    self = [super init];
    writeQueue = [[JTGlobal sharedGlobal].writeQueue retain];
    readQueue = [[NSOperationQueue alloc] init];
    return self;
}

- (void) cancelReadRequests
{
    [readQueue cancelAllOperations];
}

- (void)dealloc
{
    [readQueue cancelAllOperations];
    [readQueue release];
    
    [writeQueue release];
    
    [super dealloc];
}
@end
