//
//  JTTagService.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTTagService.h"
#import "JTServiceHTTPRequest.h"
#import "JTServiceFormDataRequest.h"
#import "JTServiceURLs.h"

@implementation JTTagService

- (void) getAllForYourAccount:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/getAllForAccount"];
    JTServiceHttpRequest *request = [[[JTServiceHttpRequest alloc] initWithURL:url] autorelease];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [readQueue addOperation:request];
}

- (void) create:(NSString*)name destLat:(double) destLat destLon:(double)destLon destinationAccuracy:(int)destinationAccuracy delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSString *strLat = [[NSString alloc] initWithFormat:@"%f",destLat];
    NSString *strLon = [[NSString alloc] initWithFormat:@"%f",destLon];    
    NSString *destinationAccuracyStr = [[NSString alloc] initWithFormat:@"%d",destinationAccuracy];    
    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/create"];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:name forKey:@"name"];
    [request setPostValue:strLat forKey:@"destLat"];
    [request setPostValue:strLon forKey:@"destLon"];
    [request setPostValue:destinationAccuracyStr forKey:@"destinationAccuracy"];
    
    
    [strLat release];
    [strLon release];
    [destinationAccuracyStr release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];
    [request release];
}

- (void)delete:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/delete"];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:tagKey forKey:@"tagKey"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];
    [request release];
}

- (void) updateTagWithKey:(NSString*) tagKey name:(NSString*)name destLat:(float)destLat destLon:(float)destLon destinationAccuracy:(int)destinationAccuracy delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSString *strLat = [[NSString alloc] initWithFormat:@"%f",destLat];
    NSString *strLon = [[NSString alloc] initWithFormat:@"%f",destLon];    
    NSString *destinationAccuracyStr = [[NSString alloc] initWithFormat:@"%d",destinationAccuracy];    
    
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/update"];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:tagKey forKey:@"tagKey"];
    [request setPostValue:name forKey:@"name"];
    [request setPostValue:strLat forKey:@"destLat"];
    [request setPostValue:strLon forKey:@"destLon"];
    [request setPostValue:destinationAccuracyStr forKey:@"destinationAccuracy"];
    
    [strLat release];
    [strLon release];
    [destinationAccuracyStr release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];
    [request release];
}

- (void) drop:(NSString*)tagKey imageData:(NSData*)imageData lat:(double)lat lon:(double)lon delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSString *strLat = [[NSString alloc] initWithFormat:@"%f",lat]; //TODO: can I use NSNumber?
    NSString *strLon = [[NSString alloc] initWithFormat:@"%f",lon];    
    

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/drop"];
    
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:tagKey forKey:@"tagKey"];
    [request setData:imageData forKey:@"imageData"];
    [request setPostValue:strLat forKey:@"lat"];
    [request setPostValue:strLon forKey:@"lon"];
    
    [strLat release];
    [strLon release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];    
    [request release];
}

- (void) dropAndPickup:(NSString*)tagKey imageData:(NSData*)imageData lat:(double)lat lon:(double)lon delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSString *strLat = [[NSString alloc] initWithFormat:@"%f",lat];
    NSString *strLon = [[NSString alloc] initWithFormat:@"%f",lon];    
    

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/dropAndPickup"];
    
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    [request setPostValue:tagKey forKey:@"tagKey"];
    [request setData:imageData forKey:@"imageData"];
    [request setPostValue:strLat forKey:@"lat"];
    [request setPostValue:strLon forKey:@"lon"];
    
    [strLat release];
    [strLon release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];
}

- (void) dropAtDepot:(NSString*)tagKey depotKey:(NSString*)depotKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{   

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/dropAtDepot"];
    
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    [request setPostValue:tagKey forKey:@"tagKey"];
    [request setPostValue:depotKey forKey:@"depotKey"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];    
}

- (void) pickup:(NSString*) tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/pickup"];
    JTServiceFormDataRequest *request = [[[JTServiceFormDataRequest alloc] initWithURL:url] autorelease];
    [request setPostValue:tagKey forKey:@"tagKey"];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];
}

- (void) getForCoordinate:(double)viewLat viewLon:(double)viewLon physicalLat:(double)physicalLat physicalLon:(double)physicalLon  delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    
    NSString *strViewLat = [[NSString alloc] initWithFormat:@"%f",viewLat];
    NSString *strViewLon = [[NSString alloc] initWithFormat:@"%f",viewLon];    
    
    NSString *strPhysicalLat = [[NSString alloc] initWithFormat:@"%f",physicalLat];
    NSString *strPhysicalLon = [[NSString alloc] initWithFormat:@"%f",physicalLon];    
    
    NSArray *params = [[NSArray alloc] initWithObjects:@"viewLat",strViewLat,@"viewLon",strViewLon,@"physicalLon",strPhysicalLon, @"physicalLat",strPhysicalLat, nil];
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/getForCoordinate" withParameters:params];
    JTServiceHttpRequest *request = [[[JTServiceHttpRequest alloc] initWithURL:url] autorelease];
    
    [params release];
    
    [strViewLat release];
    [strViewLon release];
    [strPhysicalLat release];
    [strPhysicalLon release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [readQueue addOperation:request];    
}

- (void) get:(NSString*)tagKey  delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{

    
    NSArray *params = [[NSArray alloc] initWithObjects:@"tagKey",tagKey,nil];
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/get" withParameters:params];
    JTServiceHttpRequest *request = [[[JTServiceHttpRequest alloc] initWithURL:url] autorelease];
    
    [params release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [readQueue addOperation:request];    
}

- (void)problem:(NSString*)tagKey problemCode:(int)problemCode delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail
{
    NSNumber *problemCodeNumber = [[NSNumber alloc] initWithInt:problemCode];
    NSURL *url = [JTServiceURLs serviceUrlWithPath:@"/data/tag/problem"];
    JTServiceFormDataRequest *request = [[JTServiceFormDataRequest alloc] initWithURL:url];
    [request setPostValue:tagKey forKey:@"tagKey"];
    [request setPostValue:problemCodeNumber forKey:@"problemCode"];
    
    [problemCodeNumber release];
    
    [request setDelegate:delegate];
    [request setDidFinishSelector:didFinish];
    [request setDidFailSelector:didFail];
    
    [writeQueue addOperation:request];
    [request release];
}

@end
