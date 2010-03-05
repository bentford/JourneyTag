//
//  NetworkUtil.m
//  JourneyTag
//
//  Created by Ben Ford on 8/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NetworkUtil.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "JTServiceURLs.h"

@implementation NetworkUtil

+ (void)checkForNetwork
{
    if(![NetworkUtil isHostReachable:[JTServiceURLs host]] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Unavailable" message:@"A network connection was not available. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release]; 
    }
}

+ (BOOL)isHostReachable:(NSString *)host
{
    if (!host || ![host length]) {
        return NO;
    }
    
    SCNetworkReachabilityFlags		flags;
    SCNetworkReachabilityRef reachability =  SCNetworkReachabilityCreateWithName(NULL, [host UTF8String]);
	BOOL gotFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    
	CFRelease(reachability);
    
    return gotFlags;
}
@end
