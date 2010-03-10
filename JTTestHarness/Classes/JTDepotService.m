//
//  JTDepotService.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTDepotService.h"
#import "JTServiceHTTPRequest.h"
#import "JTServiceFormDataRequest.h"
#import "JTServiceURLs.h"

@implementation JTDepotService

- (void) get:(NSString*)depotKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSArray *params = [[NSArray alloc] initWithObjects:@"depotKey",depotKey,nil];
    NSURL *url = [[JTServiceURLs serviceUrlWithPath:@"/data/depot/get" withParameters:params] retain];
    JTServiceHttpRequest *request = [[[JTServiceHttpRequest alloc] initWithURL:url] autorelease];

    [params release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
    
}

- (void) getAllByStatus:(BOOL) pickedUp delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{


    NSString *pickedUpStr = [[NSString alloc] initWithFormat:@"%@", pickedUp ? @"True" : @"False"];
    NSArray *params = [[NSArray alloc] initWithObjects:@"pickedUp",pickedUpStr,nil];
    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/depot/getAllForAccount" withParameters:params];
    JTServiceHttpRequest *request = [[[JTServiceHttpRequest alloc] initWithURL:url] autorelease];    
    
    [pickedUpStr release];
    [params release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
}

- (void) getAllAsTargetForTag:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    
    NSArray *params = [[NSArray alloc] initWithObjects:@"tagKey",tagKey,nil];
    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/depot/getAllAsTargetForTag" withParameters:params];
    JTServiceHttpRequest *request = [[[JTServiceHttpRequest alloc] initWithURL:url] autorelease];    
    
    [params release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
}


- (void) create:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/depot/create"];
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    [request setPostValue:@"blank" forKey:@"blank"]; //without this it doesn't post
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
}

- (void) drop:(NSString*)depotKey imageData:(NSData*)imageData lat:(double)lat lon:(double)lon delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    
    NSString *strLat = [[NSString alloc] initWithFormat:@"%f",lat];
    NSString *strLon = [[NSString alloc] initWithFormat:@"%f",lon];    
    
    NSURL *url = [[JTServiceURLs serviceUrlWithPath:@"/data/depot/drop"] retain];
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    [request setPostValue:depotKey forKey:@"depotKey"];
    [request setPostValue:strLat forKey:@"lat"];
    [request setPostValue:strLon forKey:@"lon"];
    [request setData:imageData forKey:@"imageData"];
    
    [strLat release];
    [strLon release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
}

- (void) pickup:(NSString*)depotKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    
    NSURL *url = [[JTServiceURLs serviceUrlWithPath:@"/data/depot/pickup"] retain];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:depotKey forKey:@"depotKey"];

    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
}


@end
