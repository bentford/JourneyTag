//
//  JTServiceFormDataRequest.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTServiceFormDataRequest.h"
#import "TouchJSON.h"

@implementation JTServiceFormDataRequest

- (void) requestFinished
{
    NSDictionary *dict = [TouchJSON parseJson:[self responseString]];
    if (self.didFinishSelector && ![self isCancelled] && [self.delegate respondsToSelector:self.didFinishSelector]) 
    {
		[self.delegate performSelectorOnMainThread:self.didFinishSelector withObject:dict waitUntilDone:[NSThread isMainThread]];		
    }
}

@end
