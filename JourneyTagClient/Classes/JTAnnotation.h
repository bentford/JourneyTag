//
//  Tag.h
//  MapKit1
//
//  Created by Ben Ford on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

enum {
    JTAnnotationTypeTag = 0,
    JTAnnotationTypeDepot
};
typedef NSUInteger JTAnnotationType;

@interface JTAnnotation : NSObject 
<MKAnnotation>
{
    NSString *myKey;
    CLLocationCoordinate2D myCoordinate;
    NSString *myTitle;
    NSString *mySubtitle;
    JTAnnotationType myType;

    int myLevel;
    BOOL myWithinPickupRange;
    
    NSString *progressMeterText;
    CGFloat distanceTraveled;
    CGFloat totalDistance;
}
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic) JTAnnotationType type;
@property (readonly) NSString *title;
@property (readonly) NSString *subTitle;
@property (readonly) BOOL withinPickupRange;
@property (readonly) NSString *key;
@property (readonly) int level;
@property (readonly) NSString *progressMeterText;
@property (readonly) CGFloat distanceTraveled;
@property (readonly) CGFloat totalDistance;

- (id)init:(NSString*)key coordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title subTitle:(NSString*)subTitle level:(int)level withinPickupRange:(BOOL)withinPickupRange progressMeterText:(NSString *)theProgressMeterText distanceTraveled:(CGFloat)theDistanceTraveled totalDistance:(CGFloat)theTotalDistance;

// TODO add this default constructor for depots
//- (id)init:(NSString*)key coordinate:(CLLocationCoordinate2D)coordinate title:(NSString*)title subTitle:(NSString*)subTitle level:(int)level withinPickupRange:(BOOL)withinPickupRange;
- (void)buttonClick:(id)sender;

- (NSString*)title;
- (NSString*)subtitle;
@end
