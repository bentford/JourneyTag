//
//  JTAccountService.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTServiceBase.h"

@interface JTAccountService : JTServiceBase {

}
- (void) createAccount:(NSString*)uuid username:(NSString*)username password:(NSString*)password email:(NSString*)email delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) login:(NSString*)uuid username:(NSString*) username password:(NSString*)password delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) logout: (id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) getAccountInfo:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void)resetPassword:(NSString*)uuid username:(NSString*)username email:(NSString*)email delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;

@end
