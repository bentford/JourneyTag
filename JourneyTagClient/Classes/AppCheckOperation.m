//
//  AppCheckOperation.m
//  JourneyTag
//
//  Created by Ben Ford on 8/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppCheckOperation.h"

#define kSimulatorPlistSize 681
#define kDevicePlistSize 743

@implementation AppCheckOperation

- (id)initWithDelegate: (id)delegate didFinish:(SEL)didFinish
{
    self = [super init];
    valid = NO; //assume the worst
    myDelegate = [delegate retain];
    myDidFinish = didFinish;
    return self;
}

- (void)main
{
    valid = [self checkPlistSize];
    
    if( valid)
        valid = [self checkPlistEncoding];

    if( valid)
        valid = [self checkForSignerIdentity];
    
  if (myDidFinish && ![self isCancelled] && [myDelegate respondsToSelector:myDidFinish]) 
  {
      NSNumber *validObject = [[NSNumber alloc] initWithBool:valid];
      [myDelegate performSelectorOnMainThread:myDidFinish withObject:validObject waitUntilDone:[NSThread isMainThread]];		
      [validObject release];
  }
}

- (BOOL)checkPlistSize
{
    path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]; 
    plistData = [NSData dataWithContentsOfFile:path];
    NSLog(@"Length is: %d",[plistData length]);
    return [plistData length] == kSimulatorPlistSize || [plistData length] == kDevicePlistSize;
}

- (BOOL)checkPlistEncoding
{
    NSString *error; 
    NSPropertyListFormat format; 

    [NSPropertyListSerialization propertyListFromData:plistData 
                                             mutabilityOption:NSPropertyListImmutable 
                                                       format:&format 
                                             errorDescription:&error]; 
    return format == NSPropertyListBinaryFormat_v1_0;
}

- (BOOL)checkForSignerIdentity
{
    NSDictionary *plistDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    BOOL result = [plistDict objectForKey:@"SignerIdentity"] == nil;
    [plistDict release];
    return result;
}

- (void)dealloc
{
    [myDelegate release];
    
    [super dealloc];
}
@end


