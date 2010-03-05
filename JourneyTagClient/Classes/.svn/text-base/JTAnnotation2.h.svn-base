//
//  JTAnnotation2.h
//  JourneyTag
//
//  Created by Ben Ford on 7/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JTAnnotation2 : NSObject 
<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *myTitle;
    NSString *mySubTitle;
}
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString*)title subtitle:(NSString*)subtitle;
- (NSString*)title;
- (NSString*)subtitle;
- (void)setTitle:(NSString*)title;
@end
