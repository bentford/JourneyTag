//
//  InfoUtil.m
//  GuestInfo
//
//  Created by Ben Ford on 12/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InfoUtil.h"


@implementation InfoUtil

+ (NSString*)appVersion {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:path];

    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *verboseVersion = [NSString stringWithFormat:@"Version %@", version];
    
    [info release];

    return verboseVersion;
}
@end
