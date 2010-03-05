//
//  JTAccountService.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTServiceBase2.h"

@interface JTAccountService : JTServiceBase2 {

}
- (void) createAccount:(NSString*)uuid username:(NSString*)username password:(NSString*)password email:(NSString*)email delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) login:(NSString*)uuid username:(NSString*) username password:(NSString*)password delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) logout: (id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) getAccountInfo:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;

- (BOOL) hasSignInCookie;
- (void) deleteCookie;

- (void)resetPassword:(NSString*)uuid username:(NSString*)username email:(NSString*)email delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) changePassword:(NSString*)newPassword delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) changeEmail:(NSString*)newEmail delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;

- (void) requestTransferCode:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) transferAccountWithUsername:(NSString*)username password:(NSString*)password email:(NSString*)email uuid:(NSString*)uuid token:(NSString*)token delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;

- (void)reportPirateWithUuid:(NSString*)uuid delegate:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
@end
