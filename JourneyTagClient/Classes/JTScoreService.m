//
//  JTScoreService.m
//  JTTestHarness1
//
//  Created by Ben Ford on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTScoreService.h"
#import "JTServiceHTTPRequest.h"
#import "JTServiceURLs.h"

@implementation JTScoreService


- (void) getPhotoScores:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
{    
    NSArray *params = [[NSArray alloc] initWithObjects:@"dummy",@"1",nil]; //required to have a parameter
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/score/getPhotoScores" withParameters:params];
    ASIHTTPRequest *request = [[JTServiceHttpRequest alloc] initWithURL:url];
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [params release];
    
    [readQueue addOperation:request];
    [request release];
}

- (void) getCarryScores:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSArray *params = [[NSArray alloc] initWithObjects:@"dummy",@"1",nil]; //required to have a parameter
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/score/getCarryScores" withParameters:params];
    ASIHTTPRequest *request = [[JTServiceHttpRequest alloc] initWithURL:url];
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [params release];
    
    [readQueue addOperation:request];
    [request release];    
}

@end
