//
//  JTServiceFormDataRequestPhoto.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTServiceFormDataRequestData.h"


@implementation JTServiceFormDataRequestData

- (void) requestFinished
{
    NSData *data = [self responseData];
    if (self.didFinishSelector && ![self isCancelled] && [self.delegate respondsToSelector:self.didFinishSelector]) 
    {
		[self.delegate performSelectorOnMainThread:self.didFinishSelector withObject:data waitUntilDone:[NSThread isMainThread]];		
    }
}
@end
