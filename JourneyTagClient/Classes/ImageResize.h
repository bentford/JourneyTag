//
//  ImageResize.h
//  JourneyTag
//
//  Created by Ben Ford on 8/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageResize : NSObject {

}

//primary operation
+ (UIImage*)resizeImage:(UIImage*)image widthConstraint:(int)width heightConstraint:(int)height;

+ (UIImage*)resizeImage:(UIImage*)image byWidthConstraint:(int)width;
+ (UIImage*)resizeImage:(UIImage*)image byHeightConstraint:(int)height;
+ (UIImage*)resizeImage:(UIImage*)image newSize:(CGSize)size;
@end
