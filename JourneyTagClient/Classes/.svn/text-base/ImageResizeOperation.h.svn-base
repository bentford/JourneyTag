//
//  ImageResizeOperation.h
//  JourneyTag
//
//  Created by Ben Ford on 7/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageResizeOperation : NSOperation {
    UIImage *myImage;
    SEL didFinishSelector;
    id myDelegate;
}

- (id)initWithImage:(UIImage*)image delegate:(id)delegate didFinish:(SEL)didFinish;
- (void)didFinishResize:(NSData*)imageData;
- (UIImage*)resizeImage:(UIImage*)image toSize:(CGSize)newSize;

@end
