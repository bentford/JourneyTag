//
//  TagMapLoader.m
//  JourneyTag1
//
//  Created by Ben Ford on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagMapLoader.h"
#import "JTAnnotation.h"
#import "DistanceTextUtil.h"

@implementation TagMapLoader


+ (void) loadDepot:(MKMapView*) mapView dictionary:(NSDictionary*)depot
{
    [TagMapLoader removeAllJTAnnotationsFromMap:mapView forType:JTAnnotationTypeDepot];
    
    CLLocationCoordinate2D newCoordinate;
    newCoordinate.latitude =  [[[depot objectForKey:@"coordinate"] objectForKey:@"lat"] doubleValue];
    newCoordinate.longitude =  [[[depot objectForKey:@"coordinate"] objectForKey:@"lon"] doubleValue];    
    
    NSString *depotName = [[NSString alloc] initWithFormat:@"Depot #%@",[depot objectForKey:@"number"]];
    
    JTAnnotation *marker = [[JTAnnotation alloc] init:[depot objectForKey:@"key"] coordinate:newCoordinate title:depotName subTitle:nil];
    marker.type = JTAnnotationTypeDepot;
    [depotName release];
    
    [mapView addAnnotation:marker];
    [marker release];
}

+ (void)removeAllJTAnnotationsFromMap:(MKMapView*) mapView forType:(JTAnnotationType)type {
    [TagMapLoader removeAllJTAnnotationsFromMap:mapView forType:type excludeTagKey:nil];
}

+ (void)removeAllJTAnnotationsFromMap:(MKMapView*) mapView forType:(JTAnnotationType)type excludeTagKey:(NSString *)excludeTagKey {    
    
    NSMutableArray *removeList = [[NSMutableArray alloc] initWithCapacity:0];
    
    for( id<MKAnnotation> ob in mapView.annotations )
    {
        if( [ob isKindOfClass:[JTAnnotation class]] )
        {
            JTAnnotation *annotation = (JTAnnotation*)ob;
            if( annotation.type == type && [annotation.key isEqualToString:excludeTagKey] == NO )
            {
                [removeList addObject:annotation];
            }
        }
    }


    for( JTAnnotation *annotation in removeList)
    {
        [mapView removeAnnotation:annotation];
    }
    
    [removeList release];    
}

+ (void)removeJTAnnotationFromMap:(MKMapView *)mapView forTagKey:(NSString *)tagKey {
    int count = [mapView.annotations count];
    
    NSMutableArray *removeList = [[NSMutableArray alloc] initWithCapacity:0];
    for( int i = 0; i < count; i++ )
    {
        id<MKAnnotation> ob = [mapView.annotations objectAtIndex:i];
        if( [ob isKindOfClass:[JTAnnotation class]] )
        {
            JTAnnotation *annotation = (JTAnnotation*)ob;
            if( [annotation.key isEqualToString:tagKey] ) { 
                [removeList addObject:annotation];
            }
        }
    }
    
    for( JTAnnotation *annotation in removeList) {
        [mapView removeAnnotation:annotation];
    }
    [removeList release];
}

+ (void) loadTag:(MKMapView*)mapView lat:(double)lat lon:(double)lon
{
    CLLocationCoordinate2D newCoordinate;
    newCoordinate.latitude = lat;
    newCoordinate.longitude = lon;
    
    JTAnnotation *marker = [[JTAnnotation alloc] init:nil coordinate:newCoordinate title:@"test" subTitle:@"test again"];
    
    [mapView addAnnotation:marker];
    [marker release];
}

+ (BOOL)loadTags:(MKMapView*)mapView tags:(NSArray*)tags
{
    return [TagMapLoader loadTags:mapView tags:tags excludeSelectedTagKey:nil];
}

+ (BOOL) loadTags:(MKMapView*)mapView tags:(NSArray*)tags excludeSelectedTagKey:(NSString *)excludeTagKey
{
    BOOL containsReachableTags = NO;
    [TagMapLoader removeAllJTAnnotationsFromMap:mapView forType:JTAnnotationTypeTag excludeTagKey:excludeTagKey];
    for( NSDictionary *tag in tags)
    {
        NSString *tagKey = [tag objectForKey:@"key"];
        
        // skip excluded tags
        if( [excludeTagKey isEqualToString:tagKey] )
            continue;
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[[tag objectForKey:@"currentCoordinate"] objectForKey:@"lat"] floatValue];
        coordinate.longitude = [[[tag objectForKey:@"currentCoordinate"] objectForKey:@"lon"] floatValue];
        
        CLLocationCoordinate2D destination;
        destination.latitude = [[[tag objectForKey:@"destinationCoordinate"] objectForKey:@"lat"] floatValue]; 
        destination.longitude = [[[tag objectForKey:@"destinationCoordinate"] objectForKey:@"lon"] floatValue]; 
        
        NSString *subtitle = [NSString stringWithFormat:@"by: %@", [tag objectForKey:@"account_username"]];
        NSString *destinationDirection = [DistanceTextUtil createDistanceTextFromCurrentLocation:coordinate destinationCoordinate:destination];
        
        NSString *withinPickupRangeString = [tag objectForKey:@"withinPickupRange"];
        BOOL withinPickupRange = [withinPickupRangeString compare:@"True"] == NSOrderedSame;
        
        if( !containsReachableTags && withinPickupRange )
            containsReachableTags = YES;
        
        CGFloat distanceTraveled = [[tag objectForKey:@"distanceTraveled"] floatValue];
        CGFloat distanceRemaining = [GreatCircleDistance distance:coordinate second:destination];
        CGFloat totalDistance = distanceTraveled + distanceRemaining;
        
        NSString *progressMeterText = [NSString stringWithFormat:@"%1.2f of %1.2f miles", distanceTraveled, totalDistance];
        
        
        
        JTAnnotation *marker = [[JTAnnotation alloc] init:tagKey coordinate:coordinate title:[tag objectForKey:@"name"] subTitle:subtitle level:[[tag objectForKey:@"level"] intValue] withinPickupRange:withinPickupRange progressMeterText:progressMeterText distanceTraveled:distanceTraveled totalDistance:totalDistance destinationCoordinate:destination destinationDirection:destinationDirection];
        
        [mapView addAnnotation:marker];
        [marker release];
    }
    return containsReachableTags;
}
@end
