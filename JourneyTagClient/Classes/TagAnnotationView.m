//
//  TagAnnotationView.m
//  JourneyTag
//
//  Created by Ben Ford on 6/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagAnnotationView.h"
#import "JTAnnotation.h"

#define kHeight 65
#define kWidth  58
#define kBorder 0

@implementation TagAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    self.frame = CGRectMake(0, 0, kWidth, kHeight);
    JTAnnotation *tagAnnotation = (JTAnnotation*)annotation;

    int level = tagAnnotation.level; //completely named wrong    
    BOOL withinPickupRange = [tagAnnotation withinPickupRange];
    
    [TagAnnotationView addEmblem:self withinPickupRange:withinPickupRange level:level];

    // this is a hack, it hides the built-in callout view
    self.calloutOffset = CGPointMake(1000, 1000);
    return self;	
}

+ (void)addEmblem:(MKAnnotationView*)annotationView withinPickupRange:(BOOL)withinPickupRange level:(int)level
{
   annotationView.frame = CGRectMake(0, 0, kWidth, kHeight);
    UIImage *image;
    if( withinPickupRange )
    {
        image = [UIImage imageNamed:@"MapTagIconGreen4.png"];
    } else {
        image = [UIImage imageNamed:@"MapTagIconRed4.png"];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    imageView.frame = CGRectMake(kBorder, kBorder, kWidth - 2 * kBorder, kWidth - 2 * kBorder);
    
    
    [annotationView addSubview:imageView];
    [imageView release];

    NSString *scoreString = [[NSString alloc] initWithFormat:@"%d",level];
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 21, 20, 20)];
    scoreLabel.textAlignment = UITextAlignmentCenter;
    scoreLabel.backgroundColor = [UIColor clearColor];
    scoreLabel.opaque = NO;
    scoreLabel.text =scoreString;
    [scoreString release];
    
    [annotationView addSubview:scoreLabel];
    [scoreLabel release];
}

@end

