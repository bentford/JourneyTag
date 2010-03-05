//
//  WriteOperationSingleton.m
//  JourneyTag
//
//  Created by Ben Ford on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTGlobal.h"


@implementation JTGlobal
@synthesize writeQueue, username;

//taken from apple code example:  
//http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html#//apple_ref/doc/uid/TP40002974-CH4-SW32

static JTGlobal *sharedGlobalInstance = nil;

- (id)init
{
    self = [super init];
    writeQueue = [[NSOperationQueue alloc] init];
    return self;
}

+ (JTGlobal*) sharedGlobal
{
    if( sharedGlobalInstance == nil )
    {
        [[self alloc] init];// assignment not done here
    }
    return sharedGlobalInstance;
}

+ (JTGlobal*) allocWithZone:(NSZone*)zone
{
    @synchronized(self) 
    {
        if (sharedGlobalInstance == nil) {
            sharedGlobalInstance = [super allocWithZone:zone];
            return sharedGlobalInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (void)dealloc
{
    [writeQueue cancelAllOperations];
    [writeQueue release];
    
    [super dealloc];
}
@end
