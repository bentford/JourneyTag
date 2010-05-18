//
//  TagMapLoader.h
//  JourneyTag1
//
//  Created by Ben Ford on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "JTAnnotation.h"

@interface TagMapLoader : NSObject {

}

+ (void) loadDepot:(MKMapView*) mapView dictionary:(NSDictionary*)depot;

+ (void) removeAllJTAnnotationsFromMap:(MKMapView*) mapView forType:(JTAnnotationType)type;
+ (void)removeAllJTAnnotationsFromMap:(MKMapView*) mapView forType:(JTAnnotationType)type excludeTagKey:(NSString *)excludeTagKey;

+ (void)removeJTAnnotationFromMap:(MKMapView *)mapView forTagKey:(NSString *)tagKey;

+ (void) loadTag:(MKMapView*)mapView lat:(double)lat lon:(double)lon;

+ (BOOL) loadTags:(MKMapView*)mapView tags:(NSArray*)tags;
+ (BOOL) loadTags:(MKMapView*)mapView tags:(NSArray*)tags excludeSelectedTagKey:(NSString *)excludeTagKey;

@end
