//
//  ImageResize.m
//  JourneyTag
//
//  Created by Ben Ford on 8/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageResize.h"


@implementation ImageResize

+ (UIImage*)resizeImage:(UIImage*)image widthConstraint:(int)width heightConstraint:(int)height
{
    if( image.size.height >= image.size.width )
        return [ImageResize resizeImage:image byHeightConstraint:height];
    else 
        return [ImageResize resizeImage:image byWidthConstraint:width];
}

+ (UIImage*)resizeImage:(UIImage*)image byWidthConstraint:(int)width
{
    float ratio = image.size.width / image.size.height;
    int height = width / ratio;
    
    CGSize newSize;
    newSize.width = width;
    newSize.height = height;
    
    return [self resizeImage:image newSize:newSize];
}

+ (UIImage*)resizeImage:(UIImage*)image byHeightConstraint:(int)height
{
    float ratio = image.size.height / image.size.width;
    int width = height / ratio;
    
    CGSize newSize;
    newSize.width = width;
    newSize.height = height;    
    
    return [self resizeImage:image newSize:newSize];
}

+ (UIImage*)resizeImage:(UIImage*)image newSize:(CGSize)size
{
    UIGraphicsBeginImageContext( size );
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

@end
