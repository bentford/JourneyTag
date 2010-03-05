//
//  MapViewUtil.m
//  JourneyTag
//
//  Created by Ben Ford on 6/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapViewUtil.h"
#import "JTAnnotation.h"

@implementation MapViewUtil

+ (BOOL)tagsAreVisibleForMapView:(MKMapView*)mapView 
{
    for( <MKAnnotation>annotation in mapView.annotations )
    {
        if( [annotation isKindOfClass:[JTAnnotation class]] )
        {
            UIView *tagView = [mapView viewForAnnotation:annotation];

            if(tagView && CGRectContainsRect(mapView.annotationVisibleRect, tagView.frame) ) 
            {
                return YES;
            }
        }
    }
    return NO;
}

@end
