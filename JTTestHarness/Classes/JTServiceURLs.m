//
//  JTServiceURLs.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "JTServiceURLs.h"


@implementation JTServiceURLs

+ (NSString*) host
{
    //return @"http://journeytag-test.appspot.com"; //should be string constant?  how do I do this?
    return @"http://localhost:8085";
}

+ (NSURL*) serviceUrlWithPath:(NSString*)path
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@",[self host],path];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    [urlString release];
    
    return [url autorelease];
}

+ (NSURL*) serviceUrlWithPath:(NSString*)path withParameters:(NSArray*)parameters
{
    NSString *params = [self buildParameterStringFromArray:parameters];
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@%@",[self host],path,params];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    [urlString release];
    
    return [url autorelease];
}

+ (NSString*) buildParameterStringFromArray:(NSArray*)array
{
    NSString *params = [[[NSString alloc] init]autorelease];
    BOOL name = YES;
    BOOL first = YES;
    for(NSString* item in array)
    {
        if( first)
        {
            if( name )
            {
                params = [params stringByAppendingFormat:@"?%@",item];   
                name = NO;
            } else {
                params = [params stringByAppendingFormat:@"=%@",item];   
                name = YES;
            }
            first = NO;
        } else {
            if( name )
            {
                params = [params stringByAppendingFormat:@"&%@",item];   
                name = NO;
            } else {
                params = [params stringByAppendingFormat:@"=%@",item];   
                name = YES;
            }
        }
    }
    return params;
}
@end
