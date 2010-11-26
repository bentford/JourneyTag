//
//  MapPipperView.m
//  JourneyTag
//
//  Created by Ben Ford on 11/26/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import "MapPipperView.h"
#define kLineWidth 2.0

@implementation MapPipperView

- (id)initWithFrame:(CGRect)frame {
	if( self = [super initWithFrame:frame] ) {
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext(); 
    UIColor *lineColor = [UIColor blueColor];
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    
    CGContextSetLineWidth(context,kLineWidth);
    
    CGRect centerSquare = CGRectMake(2.0, 2.0, rect.size.width-4.0, rect.size.height-4.0);
	NSLog(@"rect: %@", NSStringFromCGRect(centerSquare));
    CGContextAddRect(context, centerSquare);
    CGContextStrokePath(context);
}
@end
