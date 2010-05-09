//
//  LatestPhotoViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 Ben Ford. All rights reserved.
//

#import "LatestPhotoViewController.h"
#import "JTGameService.h"
#import "JTPhotoService.h"
#import "TagImageViewController.h"

#define kNumberOfPhotos 10

@interface LatestPhotoViewController(PrivateMethods)
- (void)scrollToCurrentIndex;
- (void)addToScrollView:(TagImageViewController*)controller pageNumber:(int)pageNumber;
- (void)setupScrollView;
- (void)releasePage:(int)pageNumber;
- (void)loadPage:(int)pageNumber;
@end

@interface LatestPhotoViewController()
@property (nonatomic,retain) NSArray *photos;
@end

@implementation LatestPhotoViewController
@synthesize photos;

- (id)init {
    if( self = [super init] ) {
        gameService = [[JTGameService alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Lastest Photos";
    
    [gameService getLastTenPhotosWithDelegate:self didFinish:@selector(didGetPhotos:) didFail:@selector(didFail:)];
}
#pragma mark JTGameService
- (void)didGetPhotos:(NSDictionary *)data {
    self.photos = [data objectForKey:@"photoKeys"];

    [self setupScrollView];
    
    currentIndex = 0;
    [self scrollToCurrentIndex];
}

- (void)didFail:(ASIHTTPRequest *)request {
    
}
#pragma mark -

#pragma mark JTPhotoService

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if( currentIndex != page )
    {
        [self releasePage:page-5];
        [self releasePage:page+5];
        [self loadPage:page];
    }
}

- (void)dealloc {
    [super dealloc];
}


@end

@implementation LatestPhotoViewController(PrivateMethods) 

#pragma mark scroll view
- (void)setupScrollView {
    int count = [photos count];
    controllerList = [[NSMutableArray alloc] initWithCapacity:count];
    
    for(int i = 0; i < count; i++ ) {
        [controllerList addObject:[NSNull null]];
    }
    
    myScrollView.contentSize = CGSizeMake(myScrollView.frame.size.width*count,myScrollView.frame.size.height);
    myScrollView.pagingEnabled = YES;
}

- (void)addToScrollView:(TagImageViewController*)controller pageNumber:(int)pageNumber {
    if( controller.view.superview == nil ) 
    {
        CGRect frame = myScrollView.frame;
        frame.origin.x = frame.size.width * pageNumber;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [myScrollView addSubview:controller.view];
    }
}

- (void)scrollToCurrentIndex {
    CGFloat scrollTo = (CGFloat)(myScrollView.frame.size.width * (CGFloat)currentIndex);
    CGPoint point;
    point.x = scrollTo;
    point.y = 0;
    myScrollView.contentOffset = point;;
    
    [self loadPage:currentIndex];
}

- (void)releasePage:(int)pageNumber {
    if( pageNumber < 0 || pageNumber > [photos count]-1)
    {
        return;
    }
    [controllerList replaceObjectAtIndex:pageNumber withObject:[NSNull null]];
}

- (void)loadPage:(int)pageNumber {
    if( pageNumber < 0 || pageNumber > [photos count]-1) {
        return;
    }
    
    if( [controllerList count] == 0 ) return;
    
    TagImageViewController *controller = [controllerList objectAtIndex:pageNumber];
    
    if((NSNull*)controller == [NSNull null] )
    {
        controller  = [[TagImageViewController alloc] init];
        controller.photoKey = [photos objectAtIndex:pageNumber];
        
        [controllerList replaceObjectAtIndex:pageNumber withObject:controller];
        [controller autorelease];
    } 
    [self addToScrollView:controller pageNumber:pageNumber];   
}

#pragma mark -
@end