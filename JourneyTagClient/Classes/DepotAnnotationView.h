//
//  TagAnnotationView.h
//  MapKit1
//
//  Created by Ben Ford on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DepotAnnotationView : MKAnnotationView {
	UIImageView* imageView;
}
@property (nonatomic, retain) UIImageView* imageView;


@end
