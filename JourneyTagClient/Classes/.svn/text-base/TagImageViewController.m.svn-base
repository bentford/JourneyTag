//
//  TagImageViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagImageViewController.h"
#import "ASIHTTPRequest.h"
#import "JTServiceURLs.h"
#import "PlaceMarkFormatter.h"

@implementation TagImageViewController
@synthesize myImage, activity, photoKey, coordinate, flaggedOffensive, likedPhoto;

- (id)init
{
    self = [super init];
    queue = [[NSOperationQueue alloc] init];    
    photoService = [[JTPhotoService alloc] init];
    return self;
}

- (void)viewDidLoad 
{    
    if( flaggedOffensive )
        [self showFlaggedPhoto];
    else 
        [self showActualPhoto];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    myImage.image = nil;
    infoLabel.text = nil;

    [geoCoder cancel];
    [geoCoder release];
    geoCoder = nil;
    [super viewDidUnload];
}

- (void) didFinish:(ASIHTTPRequest*)request
{
    NSData *data = [request responseData];
    myImage.image = [UIImage imageWithData:data];
    
    [photoService getInfo:self.photoKey delegate:self didFinish:@selector(didLoadPhotoInfo:) didFail:@selector(didFail:)];
}

- (void) didLoadPhotoInfo:(NSDictionary*)dict
{
    coordinate.latitude = [[[dict objectForKey:@"coordinate"] objectForKey:@"lat"] floatValue];
    coordinate.longitude = [[[dict objectForKey:@"coordinate"] objectForKey:@"lon"] floatValue];
    
    if( geoCoder) {
        [geoCoder cancel];
        [geoCoder release];
        geoCoder = nil;
    }
    geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
    geoCoder.delegate = self;
    [geoCoder start];
    [activity stopAnimating];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    infoLabel.text = [PlaceMarkFormatter standardFormat:placemark]; 
}

- (void) reverseGeocoder:(MKReverseGeocoder*)geoCoder didFailWithError:(NSError*)error
{
    
}

- (void) didFail:(ASIHTTPRequest*)request
{

}

- (void) showActualPhoto
{
     infoLabel.text = @"";
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/data/photo/getData?photoKey=%@",[JTServiceURLs host],self.photoKey];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    [urlString release];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [url release];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didFinish:)];
    [request setDidFailSelector:@selector(didFail:)];
    [queue addOperation:request];
    [request release];
    
    [activity startAnimating];    
}

- (void) showFlaggedPhoto
{
    UIImage *image = [UIImage imageNamed:@"FlaggedPhoto3.png"];
    myImage.image = image;
    
    infoLabel.text = @"flagged";
}

- (void) showLikedMark:(BOOL) show
{
    if( show )
    {
        UIImage *starIcon = [UIImage imageNamed:@"StarIcon.png"];
        likeIcon = [[UIImageView alloc] initWithImage:starIcon];
        
        likeIcon.frame = CGRectMake(250, 10, 50, 50);
        [self.view insertSubview:likeIcon aboveSubview:myImage];
        [likeIcon release];
    } 
    else 
    {
        if( likeIcon != nil )
        {
            [likeIcon removeFromSuperview];
        }
    }
}

- (void)dealloc 
{    
    //stop asynchronous operations
    [queue cancelAllOperations];
    [geoCoder cancel];
    [photoService cancelReadRequests];
    
    [myImage release];
    [activity release];
    
    [likeIcon release];
    
    [photoKey release];

    [photoService release];
    [infoLabel release];
    
    [geoCoder release];
    [queue release];
    
    [super dealloc];
}


@end
