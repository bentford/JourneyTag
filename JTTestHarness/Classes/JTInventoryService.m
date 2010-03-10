//
//  JTInventoryService.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTInventoryService.h"
#import "JTServiceHTTPRequest.h"
#import "JTServiceFormDataRequest.h"
#import "JTServiceURLs.h"

@implementation JTInventoryService

- (void) create:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/inventory/create"] ;
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    [request setPostValue:tagKey forKey:@"tagKey"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
}


- (void) delete:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/inventory/delete"];
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    [request setPostValue:tagKey forKey:@"tagKey"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];    
    
    [queue addOperation:request];
}

- (void) get:(NSString*)accountKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSArray *params = [[NSArray alloc] initWithObjects:@"accountKey",accountKey,nil];
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/inventory/all" withParameters:params];
    ASIHTTPRequest *request = [[[JTServiceHttpRequest alloc] initWithURL:url] autorelease];
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [params release];
    
    [queue addOperation:request];
}
@end
