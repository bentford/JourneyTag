//
//  TagAnnotationView.m
//  MapKit1
//
//  Created by Ben Ford on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DepotAnnotationView.h"

#define kHeight 38
#define kWidth  42
#define kBorder 0

@implementation DepotAnnotationView
@synthesize imageView;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	self.frame = CGRectMake(0, 0, kWidth, kHeight);
	
	UIImage* image = [UIImage imageNamed:@"MapDepotIcon2.png"];
	imageView = [[UIImageView alloc] initWithImage:image];
	
	imageView.frame = CGRectMake(kBorder, kBorder, kWidth - 2 * kBorder, kHeight - 2 * kBorder);
	[self addSubview:imageView];
	[imageView release];
    
	return self;	
}

@end
