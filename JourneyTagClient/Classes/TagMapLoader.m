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
    
    JTAnnotation *marker = [[JTAnnotation alloc] init:[depot objectForKey:@"key"] coordinate:newCoordinate title:depotName subTitle:nil level:0 withinPickupRange:NO];
    marker.type = JTAnnotationTypeDepot;
    [depotName release];
    
    [mapView addAnnotation:marker];
    [marker release];
}

+ (void)removeAllJTAnnotationsFromMap:(MKMapView*) mapView forType:(JTAnnotationType)type {    
    
    NSMutableArray *removeList = [[NSMutableArray alloc] initWithCapacity:0];
    
    for( id<MKAnnotation> ob in mapView.annotations )
    {
        if( [ob isKindOfClass:[JTAnnotation class]] )
        {
            JTAnnotation *annotation = (JTAnnotation*)ob;
            if( annotation.type == type )
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

+ (void) loadTag:(MKMapView*)mapView lat:(double)lat lon:(double)lon
{
    CLLocationCoordinate2D newCoordinate;
    newCoordinate.latitude = lat;
    newCoordinate.longitude = lon;
    
    JTAnnotation *marker = [[JTAnnotation alloc] init:nil coordinate:newCoordinate title:@"test" subTitle:@"test again" level:0 withinPickupRange:NO];
    
    [mapView addAnnotation:marker];
    [marker release];
}

+ (BOOL) loadTags:(MKMapView*)mapView tags:(NSArray*)tags
{
    BOOL containsReachableTags = NO;
    [TagMapLoader removeAllJTAnnotationsFromMap:mapView forType:JTAnnotationTypeTag];
    for( NSDictionary *tag in tags)
    {
        NSString *tagKey = [tag objectForKey:@"key"];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[[tag objectForKey:@"currentCoordinate"] objectForKey:@"lat"] floatValue];
        coordinate.longitude = [[[tag objectForKey:@"currentCoordinate"] objectForKey:@"lon"] floatValue];
        
        CLLocationCoordinate2D destination;
        destination.latitude = [[[tag objectForKey:@"destinationCoordinate"] objectForKey:@"lat"] floatValue]; 
        destination.longitude = [[[tag objectForKey:@"destinationCoordinate"] objectForKey:@"lon"] floatValue]; 
        
        //NSString *subtitle = [tag objectForKey:@"account_username"];
        NSString *subtitle = [DistanceTextUtil createDistanceTextFromCurrentLocation:coordinate destinationCoordinate:destination];
        
        NSString *withinPickupRangeString = [tag objectForKey:@"withinPickupRange"];
        BOOL withinPickupRange = [withinPickupRangeString compare:@"True"] == NSOrderedSame;
        
        if( !containsReachableTags && withinPickupRange )
            containsReachableTags = YES;
        
        JTAnnotation *marker = [[JTAnnotation alloc] init:tagKey coordinate:coordinate title:[tag objectForKey:@"name"] subTitle:subtitle level:[[tag objectForKey:@"level"] intValue] withinPickupRange:withinPickupRange];
        
        [mapView addAnnotation:marker];
        [marker release];
    }
    return containsReachableTags;
}
@end
