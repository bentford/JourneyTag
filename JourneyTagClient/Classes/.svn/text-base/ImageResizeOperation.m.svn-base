//
//  ImageResizeOperation.m
//  JourneyTag
//
//  Created by Ben Ford on 7/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageResizeOperation.h"


@implementation ImageResizeOperation
- (id)initWithImage:(UIImage*)image delegate:(id)delegate didFinish:(SEL)didFinish
{
    if(self = [super init] )
    {
        myImage = [image retain];
        didFinishSelector = didFinish;
        myDelegate = [delegate retain];
    }
    return self;
}

- (void)main
{
    UIImage *resizedImage = [self resizeImage:myImage toSize:CGSizeMake(320,480)];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, .3);
    [self didFinishResize:imageData];
}

- (void)didFinishResize:(NSData*)imageData
{
    if (didFinishSelector && ![self isCancelled] && [myDelegate respondsToSelector:didFinishSelector]) 
    {
        [myDelegate performSelectorOnMainThread:didFinishSelector withObject:imageData waitUntilDone:[NSThread isMainThread]];		
    }
}

- (UIImage*)resizeImage:(UIImage*)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)dealloc
{
    [myImage release];
    [myDelegate release];
    [super dealloc];
}
@end
