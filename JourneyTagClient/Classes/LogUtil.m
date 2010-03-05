//
//  LogUtil.m
//  JourneyTag
//
//  Created by Ben Ford on 8/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LogUtil.h"
#import "JTGlobal.h"

@implementation LogUtil

+ (NSString*)logKeyForString:(NSString*)string
{
    return [[[NSString alloc] initWithFormat:@"%@_%@",[JTGlobal sharedGlobal].username,string] autorelease];
}
@end
