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
    return [self host:NO];
}

+ (NSString*) host:(BOOL)secure
{
    if( [[UIDevice currentDevice].uniqueIdentifier compare:@"00000000-0000-1000-8000-001FF344D40B"] == NSOrderedSame )
        return @"http://localhost:8085";        
    else
        return secure ? @"https://journeytag.appspot.com" : @"http://journeytag.appspot.com";
}

+ (NSURL*) serviceUrlWithPath:(NSString*)path
{
    return [self serviceUrlWithPath:path secure:NO];
}

+ (NSURL*) serviceUrlWithPath:(NSString*)path secure:(BOOL)secure
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@",[self host:secure],path];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    [urlString release];
    
    return [url autorelease];
}

+ (NSURL*) serviceUrlWithPath:(NSString*)path withParameters:(NSArray*)parameters secure:(BOOL)secure
{
    NSString *params = [self buildParameterStringFromArray:parameters];
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@%@",[self host:secure],path,params];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    [urlString release];
    
    return [url autorelease];    
}

+ (NSURL*) serviceUrlWithPath:(NSString*)path withParameters:(NSArray*)parameters
{
    return [self serviceUrlWithPath:path withParameters:parameters secure:NO];
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
