//
//  AppCheckOperation.h
//  JourneyTag
//
//  Created by Ben Ford on 8/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppCheckOperation : NSOperation {
    BOOL valid;
    id myDelegate;
    SEL myDidFinish;
    
    NSString *path;
    NSData *plistData;
}
- (id)initWithDelegate: (id)delegate didFinish:(SEL)didFinish;
- (BOOL)checkForSignerIdentity;
- (BOOL)checkPlistEncoding;
- (BOOL)checkPlistSize;
@end
