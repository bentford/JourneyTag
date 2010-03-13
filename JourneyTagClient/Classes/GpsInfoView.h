//
//  GpsInfoView.h
//  JourneyTag
//
//  Created by Ben Ford on 3/12/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GpsInfoView : UIView {

    IBOutlet UIImageView *gpsBars;
    IBOutlet UILabel *gpsAccuracyValue;
}
- (void)updateAccuracy:(double) horizontalAccuracy;
@end
