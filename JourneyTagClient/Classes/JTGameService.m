//
//  JTGameService.m
//  JourneyTag
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import "JTGameService.h"
#import "JTServiceHTTPRequest.h"
#import "JTServiceURLs.h"

@implementation JTGameService
- (void) getAccountsByHighScoreWithDelegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail {
	
	 NSArray *params = [NSArray arrayWithObjects:@"dummy",@"1",nil]; //required to have a parameter
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/game/getAccountsByHighScore" withParameters:params];
    JTServiceHttpRequest *request = [[JTServiceHttpRequest alloc] initWithURL:url];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [readQueue addOperation:request];
    [request release];
}

- (void)getLastTenPhotosWithDelegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail {
    NSArray *params = [NSArray arrayWithObjects:@"dummy",@"1",nil]; //required to have a parameter
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/game/getLastTenPhotos" withParameters:params];
    JTServiceHttpRequest *request = [[JTServiceHttpRequest alloc] initWithURL:url];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [readQueue addOperation:request];
    [request release];
}
@end
