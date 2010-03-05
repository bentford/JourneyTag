//
//  WriteOperationSingleton.h
//  JourneyTag
//
//  Created by Ben Ford on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface JTGlobal : NSObject {
    NSOperationQueue *writeQueue;
    NSString *username;
}
@property (readonly) NSOperationQueue *writeQueue;
@property (nonatomic,retain) NSString *username;

- (id)init;
+ (JTGlobal*) sharedGlobal;
@end
