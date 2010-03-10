//
//  JTAccountService.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTAccountService.h"

#import "JTServiceHTTPRequest.h"
#import "JTServiceFormDataRequest.h"
#import "JTServiceURLs.h"

@implementation JTAccountService

- (void) createAccount:(NSString*)uuid username:(NSString*)username password:(NSString*)password email:(NSString*)email delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/create"];
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    [request setPostValue:uuid forKey:@"uuid"];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:email forKey:@"email"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    

    [queue addOperation:request];
 }


- (void) login:(NSString*)uuid username:(NSString*) username password:(NSString*)password delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/login"];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:uuid forKey:@"uuid"];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [queue addOperation:request];  
    [request release];
}

- (void) logout: (id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSArray *params = [[NSArray alloc] initWithObjects:@"logout",@"yes",nil];
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/logout" withParameters:params];
    JTServiceHttpRequest *request = [[JTServiceHttpRequest alloc] initWithURL:url];
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [params release];
    
    [queue addOperation:request];
    [request release];
}

- (void) getAccountInfo:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/getAccountInfo"];
    JTServiceHttpRequest *request = [[JTServiceHttpRequest alloc] initWithURL:url];
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [queue addOperation:request];    
    [request release];
}

- (void)resetPassword:(NSString*)uuid username:(NSString*)username email:(NSString*)email delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/resetPassword"];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:uuid forKey:@"uuid"];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:email forKey:@"email"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [queue addOperation:request];  
    [request release];
}

@end
