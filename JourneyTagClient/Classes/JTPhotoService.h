//
//  JTPhotoService.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTServiceBase2.h"

@interface JTPhotoService : JTServiceBase2 {

}
- (void) createPhoto:(NSData*)data delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) getInfo:(NSString*)photoKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) getData:(NSString*)photoKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void)getImageDataWithTagKey:(NSString*)tagKey delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) flagPhoto:(NSString*)photoKey flag:(BOOL)flag delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) likePhoto:(NSString*)photoKey like:(BOOL)like delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
@end
