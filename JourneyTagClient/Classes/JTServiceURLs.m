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
	// This is just hard coded to the two iphone simulators that I use.
    if( [[UIDevice currentDevice].uniqueIdentifier isEqualToString:@"BCDB12A8-0EA2-54AC-BCB2-B48E7165EB44"] ||
	    [[UIDevice currentDevice].uniqueIdentifier isEqualToString:@"E10ACB44-7EC0-5672-9AF7-C67EB807B653"] )
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
