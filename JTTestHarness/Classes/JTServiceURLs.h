//
//  JTServiceURLs.h
//  JTTestHarness1
//
//  Created by Ben Ford on 5/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JTServiceURLs : NSObject {

}
+ (NSString*) host;
+ (NSURL*) serviceUrlWithPath:(NSString*)path;
+ (NSURL*) serviceUrlWithPath:(NSString*)path withParameters:(NSArray*)parameters;
+ (NSString*) buildParameterStringFromArray:(NSArray*)array;
@end
