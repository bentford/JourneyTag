//
//  GpsInfoView.m
//  JourneyTag
//
//  Created by Ben Ford on 3/12/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import "GpsInfoView.h"


@implementation GpsInfoView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"GpsInfoView" owner:self options:nil];
        UIView *dropInfoView = [objects objectAtIndex:0];
        [self addSubview:dropInfoView];

        gpsAccuracyValue.text = @"?";
    }
    return self;
}

- (void)updateAccuracy:(double) horizontalAccuracy {
    gpsAccuracyValue.text = [NSString stringWithFormat:@"%1.0fm",horizontalAccuracy];
    
    if( horizontalAccuracy <= 50.0 ) 
        gpsBars.image = [UIImage imageNamed:@"GPSBars6.png"];
    else if( horizontalAccuracy > 50.0 && horizontalAccuracy <= 100.0 )
        gpsBars.image = [UIImage imageNamed:@"GPSBars5.png"];
    else if( horizontalAccuracy > 100.0 && horizontalAccuracy <= 150.0 )
        gpsBars.image = [UIImage imageNamed:@"GPSBars4.png"];
    else if( horizontalAccuracy > 150.0 && horizontalAccuracy <= 200.0 )
        gpsBars.image = [UIImage imageNamed:@"GPSBars3.png"];
    else if( horizontalAccuracy > 200.0 && horizontalAccuracy <= 250.0 )
        gpsBars.image = [UIImage imageNamed:@"GPSBars2.png"];
    else if( horizontalAccuracy > 250.0 )
        gpsBars.image = [UIImage imageNamed:@"GPSBars1.png"];
}

                        

- (void)dealloc {
    [super dealloc];
}


@end
