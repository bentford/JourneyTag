//
//  TouchJSON.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TouchJSON.h"
#import "CJSONDeserializer.h"

@implementation TouchJSON
+ (NSDictionary*) parseJson:(NSString*)string
{
    NSData *jsonData = [string dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
    
    return dict;
}
@end
