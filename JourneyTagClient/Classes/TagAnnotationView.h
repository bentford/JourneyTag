//
//  TagAnnotationView.h
//  JourneyTag
//
//  Created by Ben Ford on 6/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TagAnnotationView : MKAnnotationView  {

}

+ (void)addEmblem:(MKAnnotationView*)annotationView withinPickupRange:(BOOL)withinPickupRange level:(int)level;
@end
