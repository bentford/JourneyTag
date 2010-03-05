//
//  AppFiles.m
//  JourneyTag
//
//  Created by Ben Ford on 8/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppFiles.h"


@implementation AppFiles


+ (NSString *)pathForTagViewLog 
{ 
    return [AppFiles pathForDocumentsDirectoryFile:@"tagViewLog.plist"];
}

+ (NSString*)pathForDropSettings
{
    return [AppFiles pathForDocumentsDirectoryFile:@"dropSettings.plist"];   
}

+ (NSString *)pathForDocumentsDirectoryFile:(NSString*)filename
{ 
    NSArray *paths = NSSearchPathForDirectoriesInDomains( 
                                                         NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    return [documentsDirectory stringByAppendingPathComponent:filename]; 
}


@end
