//
//  JTServiceHttpRequest.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTServiceHttpRequest.h"
#import "TouchJSON.h"

@implementation JTServiceHttpRequest

- (void)startRequest
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [super startRequest];
}
- (void) requestFinished
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *response = [self responseString];
    if( [response compare:@"access denied"] == NSOrderedSame )
    {
        [self failWithError:nil];
    }

    NSDictionary *dict = [TouchJSON parseJson:response];

    if (self.didFinishSelector && ![self isCancelled] && self.delegate != nil && [self.delegate respondsToSelector:self.didFinishSelector]) 
    {
		[self.delegate performSelectorOnMainThread:self.didFinishSelector withObject:dict waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)failWithError:(NSError *)theError
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super failWithError:theError];
}
@end
