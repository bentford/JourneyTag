//
//  TagImageViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTPhotoService.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface TagImageViewController : UIViewController 
<MKReverseGeocoderDelegate>
{
    UIImageView *myImage;
    UIActivityIndicatorView *activity;

    UIImageView *likeIcon;
    
    NSString *photoKey;
    
    JTPhotoService *photoService;
    IBOutlet UILabel *infoLabel;
    
    CLLocationCoordinate2D coordinate;
    MKReverseGeocoder *geoCoder;
    
    BOOL flaggedOffensive;
    BOOL likedPhoto;
    
    NSOperationQueue *queue;
}
@property (nonatomic, retain) IBOutlet UIImageView *myImage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, retain) NSString *photoKey;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic) BOOL flaggedOffensive;
@property (nonatomic) BOOL likedPhoto;


- (void) showFlaggedPhoto;
- (void) showActualPhoto;

- (void) showLikedMark:(BOOL) show;
@end
