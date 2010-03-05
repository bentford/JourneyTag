//
//  JTMarkService.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTMarkService.h"
#import "JTServiceHTTPRequest.h"
#import "JTServiceFormDataRequest.h"
#import "JTServiceURLs.h"

@implementation JTMarkService
- (void) create:(NSString*)tagKey photoKey:(NSString*)photoKey lat:(double)lat lon:(double)lon delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSString *strLat = [[NSString alloc] initWithFormat:@"%f",lat];
    NSString *strLon = [[NSString alloc] initWithFormat:@"%f",lon];    

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/mark/create"];
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    [request setPostValue:tagKey forKey:@"tagKey"];
    [request setPostValue:photoKey forKey:@"photoKey"];
    [request setPostValue:strLat forKey:@"lat"];
    [request setPostValue:strLon forKey:@"lon"];        
    
    [strLat release];
    [strLon release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [writeQueue addOperation:request];
}
- (void) getAllForTag:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSArray *params = [[NSArray alloc] initWithObjects:@"tagKey",tagKey,nil];
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/mark/getAllForTag" withParameters:params];
    JTServiceHttpRequest *request = [[JTServiceHttpRequest alloc] initWithURL:url];

    [params release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [readQueue addOperation:request];
    [request release];
}
@end
