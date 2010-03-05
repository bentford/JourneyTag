//
//  DateTimeUtil.m
//  JourneyTag
//
//  Created by Ben Ford on 8/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DateTimeUtil.h"


@implementation DateTimeUtil

+ (NSString*) localDateStringFromUtcString:(NSString*)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"y-M-d H:m:s ZZZ"];
    NSDate *localDate = [formatter dateFromString:dateString];

    [formatter setDateStyle:kCFDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *resultString = [formatter stringFromDate:localDate];
    [formatter release];
 
    return resultString;
}

+ (NSDate*) localDateFromUtcString:(NSString*)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"y-M-d H:m:s ZZZ"];
    NSDate *localDate = [formatter dateFromString:dateString];
    [formatter release];
    
    return localDate;
}
@end
