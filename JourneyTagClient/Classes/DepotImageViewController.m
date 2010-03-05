//
//  DepotImageViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 5/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DepotImageViewController.h"
#import "ASIHTTPRequest.h"
#import "JTServiceURLs.h"

@implementation DepotImageViewController

- (id)initWithPhotoKey:(NSString*)photoKey
{
    self = [super init];
    
    queue = [[NSOperationQueue alloc] init];
    myPhotoKey = [photoKey retain];
    return self;
}

- (void) viewDidLoad
{
    self.title = @"Depot Image";
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.title = nil;
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/data/photo/getData?photoKey=%@",[JTServiceURLs host],myPhotoKey];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    [urlString release];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [url release];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didLoadImage:)];
    [request setDidFailSelector:@selector(didFail:)];
    
    [queue addOperation:request];    
    [request release];
    
    [activity startAnimating];
    
    [super viewDidAppear:animated];
}

- (void) didLoadImage:(ASIHTTPRequest*)request
{
    NSData *data = [request responseData];
    imageView.image = [UIImage imageWithData:data];;
    
    [activity stopAnimating];
}

- (void) didFail:(ASIHTTPRequest*)request
{
    [activity stopAnimating];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Operation Failed" message:nil delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [alertView show];
    [alertView release]; 
}

- (void)dealloc 
{
    [myPhotoKey release];
    
    [queue cancelAllOperations];
    [queue release];
    
    [super dealloc];
}


@end
