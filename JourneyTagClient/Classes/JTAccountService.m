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
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/create" secure:YES];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:uuid forKey:@"uuid"];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:email forKey:@"email"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    
    [writeQueue addOperation:request];
    [request release];
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
    
    [writeQueue addOperation:request];  
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
    
    [readQueue addOperation:request];
    [request release];
}

- (void) getAccountInfo:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/getAccountInfo"];
    JTServiceHttpRequest *request = [[[JTServiceHttpRequest alloc] initWithURL:url] autorelease];
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [readQueue addOperation:request];    
}

- (BOOL) hasSignInCookie
{
    NSArray *cookieJar = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for( NSHTTPCookie *cookie in cookieJar)
    {
        if( [[cookie name] compare: @"JourneyTagID"] == NSOrderedSame)
        {
            return YES;
        }
    }
    return NO;
}

- (void) deleteCookie
{
    NSArray *cookieJar = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for( NSHTTPCookie *cookie in cookieJar)
    {
        if( [[cookie name] compare: @"JourneyTagID"] == NSOrderedSame)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            break;
        }
    }
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
    
    [writeQueue addOperation:request];  
    [request release];
}

- (void)getUsernamesForEmail:(NSString*)email delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/getUsernamesForEmail"];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:email forKey:@"email"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];
    [request release];
}

- (void) changePassword:(NSString*)newPassword delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/changePassword" secure:YES];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:newPassword forKey:@"newPassword"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];  
    [request release];
}

- (void) changeEmail:(NSString*)newEmail delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/changeEmail"];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:newEmail forKey:@"newEmail"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];  
    [request release];
}

- (void)requestTransferCode:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/requestTransferCode"];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:@"dummy" forKey:@"dummy"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];  
    [request release];
}

- (void) transferAccountWithUsername:(NSString*)username password:(NSString*)password email:(NSString*)email uuid:(NSString*)uuid token:(NSString*)token delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/transferAccount" secure:YES];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:uuid forKey:@"uuid"];

    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];  
    [request release];
}

- (void)reportPirateWithUuid:(NSString*)uuid delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/account/reportPirate" secure:YES];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:uuid forKey:@"uuid"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];  
    [request release];
}


@end
