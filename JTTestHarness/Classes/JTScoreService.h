//
//  JTScoreService.h
//  JTTestHarness1
//
//  Created by Ben Ford on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTServiceBase.h"

@interface JTScoreService : JTServiceBase {

}

- (void) getPhotoScores:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) getCarryScores:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (void) getArriveScores:(id)delegate didFinish:(SEL)didFinish didFail:(SEL)didFail;
@end
