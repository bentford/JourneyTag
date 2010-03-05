//
//  JTEmailUtil.m
//  JourneyTag
//
//  Created by Ben Ford on 8/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTEmailUtil.h"


@implementation JTEmailUtil

+ (BOOL)validateEmail: (NSString *) email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:email];
}

@end
