//
//  JTPhotoService.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTPhotoService.h"
#import "JTServiceHTTPRequest.h"
#import "JTServiceFormDataRequest.h"
#import "JTServiceFormDataRequestData.h"
#import "JTServiceURLs.h"

@implementation JTPhotoService
- (void) createPhoto:(NSData*)data delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/photo/create"];
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    [request setData:data forKey:@"data"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
}

- (void) getInfo:(NSString*)photoKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSArray *params = [[NSArray alloc] initWithObjects:@"photoKey",photoKey,nil];
    NSURL *url = [[JTServiceURLs serviceUrlWithPath:@"/data/photo/getInfo" withParameters:params] retain];
    JTServiceHttpRequest *request = [[[JTServiceHttpRequest alloc] initWithURL:url] autorelease];
    
    [params release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
}

- (void) getData:(NSString*)photoKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSArray *params = [[NSArray alloc] initWithObjects:@"photoKey",photoKey,nil];
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/photo/getData" withParameters:params];
    JTServiceFormDataRequestData *request = [[[JTServiceFormDataRequestData alloc] initWithURL:url] autorelease];                                    
    
    [params release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [queue addOperation:request];
}

- (void)getImageDataWithTagKey:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSArray *params = [NSArray arrayWithObjects:@"tagKey",tagKey,nil];
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/photo/getImageDataWithTagKey" withParameters:params];
    JTServiceFormDataRequestData *request = [[[JTServiceFormDataRequestData alloc] initWithURL:url] autorelease];                                    
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [queue addOperation:request];
}

- (void) flagPhoto:(NSString*)photoKey flag:(BOOL)flag delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSString *flagValue = flag ? @"True" : @"False";

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/photo/flag"];
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    
    [request setPostValue:photoKey forKey:@"photoKey"];
    [request setPostValue:flagValue forKey:@"flag"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
}

- (void) likePhoto:(NSString*)photoKey like:(BOOL)like delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSString *likeValue = like ? @"True" : @"False";

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/photo/like"];
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    
    [request setPostValue:photoKey forKey:@"photoKey"];
    [request setPostValue:likeValue forKey:@"like"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [queue addOperation:request];
}

@end
