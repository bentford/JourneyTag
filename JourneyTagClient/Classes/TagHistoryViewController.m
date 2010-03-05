//
//  TagHistoryViewController.m
//  JourneyTag1
//
//  Created by Ben Ford on 4/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagHistoryViewController.h"
#import "DateTimeUtil.h"
#import "JTServiceURLs.h"
#import "ActivityButtonUtil.h"

@implementation TagHistoryViewController
@synthesize myScrollView, currentElement, controllerList, mapView, currentIndex;
@synthesize tagKey,canVote;

- (id)init
{
    self = [super init];
    
    markService = [[JTMarkService alloc] init];
    photoService = [[JTPhotoService alloc] init];
    
    return self;
}

#pragma mark init
- (void)viewDidLoad {
    self.title = @"Tag History";
    
    UIBarButtonItem *seeMapButton = [[UIBarButtonItem alloc] initWithTitle:@"See Map" style:UIBarButtonItemStylePlain target:self action:@selector(showMap)];
    self.navigationItem.rightBarButtonItem = seeMapButton;
    [seeMapButton release];
    

    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"See Info" style:UIBarButtonItemStyleBordered target:self action:@selector(infoButtonPressed:)];
    imageCounter = [[UIBarButtonItem alloc] initWithTitle:@"0 of 0" style:UIBarButtonItemStylePlain target:nil action:nil];
    if( self.canVote )
    {
        voteButtonPlaceholder = [self getVoteButton];
    } 
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 50;
    if( self.canVote )
    {
        toolbarItems = [[NSMutableArray alloc] initWithObjects:voteButtonPlaceholder, flex, imageCounter, flex, infoButton, nil];
    } else {
        toolbarItems = [[NSMutableArray alloc] initWithObjects:fixed, flex, imageCounter, flex, infoButton, nil];    
    }
    
    [flex release];
    [fixed release];
    [infoButton release];
    
    [toolbar setItems:toolbarItems animated:NO];    
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.title = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [toolbar release];
    toolbar = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadMarksForTag];
    [super viewDidAppear:animated];
}



- (BOOL)canVoteOnCurrentPhoto
{
    return [(NSString*)[canVoteList objectAtIndex:currentIndex] compare:@"True"] == NSOrderedSame;
}

- (void) loadMarksForTag
{
    [markService getAllForTag:self.tagKey delegate:self didFinish:@selector(didGetForTag:) didFail:@selector(didFail:)];
}

#pragma mark IBActions
- (IBAction) voteButtonPressed:(id)sender
{
    BOOL currentPhotoFlagged = [(NSString*)[flaggedList objectAtIndex:currentIndex] compare:@"True"] == NSOrderedSame;
    NSString *flagButtonText = currentPhotoFlagged ?  @"Undo Offensive Flag" : @"Flag Offensive";
    
    BOOL photoLiked = [(NSString*)[likedList objectAtIndex:currentIndex] compare:@"True"] == NSOrderedSame;
    NSString *likeButtonText = photoLiked ? @"Remove Award" : @"Award 100 points";
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Award points to the other player if you liked their photo." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:likeButtonText,flagButtonText, @"Cancel",nil];
    sheet.destructiveButtonIndex = 0;
    
    [sheet showInView:self.view];
    [sheet release];
}

#pragma mark JTService
- (void) didGetForTag:(NSDictionary*)dict
{
    NSArray *marks = [dict objectForKey:@"marks"];
    int markCount = [marks count];
    
    photoKeyList = [[NSMutableArray alloc] initWithCapacity:markCount];
    latList = [[NSMutableArray alloc] initWithCapacity:markCount];
    lonList = [[NSMutableArray alloc] initWithCapacity:markCount];
    flaggedList = [[NSMutableArray alloc] initWithCapacity:markCount];
    likedList = [[NSMutableArray alloc] initWithCapacity:markCount];
    canVoteList = [[NSMutableArray alloc] initWithCapacity:markCount];
    dateList = [[NSMutableArray alloc] initWithCapacity:markCount];
    
    for( NSDictionary *mark in marks)
    {
        [photoKeyList addObject:[mark objectForKey:@"photoKey"]];
        
        [latList addObject:[[mark objectForKey:@"coordinate"] objectForKey:@"lat"]];
        [lonList addObject:[[mark objectForKey:@"coordinate"] objectForKey:@"lon"]];
        [flaggedList addObject:[mark objectForKey:@"photoFlaggedOffensive"]];
        [likedList addObject:[mark objectForKey:@"photoLiked"]];
        [canVoteList addObject:[mark objectForKey:@"canVote"]];
        [dateList addObject:[mark objectForKey:@"dateCreated"]];
    }
    [self setupScrollView];
    [self loadPage:0];
}

- (void) didFail:(id)sender
{

}

#pragma mark scroll view
- (void) setupScrollView
{
    int count = [photoKeyList count];
    controllerList = [[NSMutableArray alloc] initWithCapacity:count];
    
    for(int i = 0; i < count; i++ )
    {
        [controllerList addObject:[NSNull null]];
    }
    
    myScrollView.contentSize = CGSizeMake(myScrollView.frame.size.width*count,myScrollView.frame.size.height);
    myScrollView.pagingEnabled = YES;
}

- (void)loadPage:(int)pageNumber
{
    if( pageNumber < 0 || pageNumber > [latList count]-1)
    {
        return;
    }
    
    [self updateImageCounter:pageNumber];
    
    if( [controllerList count] == 0 ) return;
    
    TagImageViewController *controller = [controllerList objectAtIndex:pageNumber];

    CLLocationCoordinate2D coord;
    coord.latitude = [[latList objectAtIndex:pageNumber] doubleValue];
    coord.longitude = [[lonList objectAtIndex:pageNumber] doubleValue];
    
    if((NSNull*)controller == [NSNull null] )
    {
        controller  = [[TagImageViewController alloc] init];
        controller.photoKey =[photoKeyList objectAtIndex:pageNumber];
        controller.coordinate = coord;
        controller.flaggedOffensive = [[flaggedList objectAtIndex:pageNumber] caseInsensitiveCompare:@"True"] == NSOrderedSame;
        controller.likedPhoto = [[likedList objectAtIndex:pageNumber] caseInsensitiveCompare:@"True"] == NSOrderedSame;
                
        [controllerList replaceObjectAtIndex:pageNumber withObject:controller];
        
        [self updateVoteButton:controller];
        
        [self addToScrollView:controller pageNumber:pageNumber];   
        [controller release];
    } else {
        [self addToScrollView:controller pageNumber:pageNumber];   
    }
}

- (void) releasePage:(int)pageNumber
{
    if( pageNumber < 0 || pageNumber > [latList count]-1)
    {
        return;
    }
    [controllerList replaceObjectAtIndex:pageNumber withObject:[NSNull null]];
}

- (void) addToScrollView:(TagImageViewController*)controller pageNumber:(int)pageNumber
{
    if( controller.view.superview == nil ) 
    {
        CGRect frame = myScrollView.frame;
        frame.origin.x = frame.size.width * pageNumber;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [myScrollView addSubview:controller.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if( currentIndex != page )
    {
        [self releasePage:page-5];
        [self releasePage:page+5];
        [self loadPage:page];
        
        TagImageViewController *controller = [controllerList objectAtIndex:currentIndex];
        [self updateVoteButton:controller];
    }
    

    
}

- (void) scrollToCurrentIndex
{
    CGFloat scrollTo = (CGFloat)(myScrollView.frame.size.width * (CGFloat)currentIndex);
    CGPoint point;
    point.x = scrollTo;
    point.y = 0;
    myScrollView.contentOffset = point;;
    
    [self loadPage:currentIndex];
}

- (void) updateImageCounter:(NSInteger)imageIndex
{
    currentIndex = imageIndex;
    
    if( [photoKeyList count] == 0 ) imageIndex = -1; //special case when no marks exist
    
    int count = [photoKeyList count];
    NSString *message = [[NSString alloc] initWithFormat:@"%d of %d", count - imageIndex, count ];
    imageCounter.title = message;
    [message release];    
}


- (void) updateVoteButton:(TagImageViewController*)controller
{
    if( !self.canVote )
    {
        return;
    }
    
    if( controller.likedPhoto )
    {
        voteButtonPlaceholder = [self getStarButton];
        [toolbarItems replaceObjectAtIndex:0 withObject:voteButtonPlaceholder];
        [toolbar setItems:toolbarItems animated:NO];    
    } else if( controller.flaggedOffensive ) {
        voteButtonPlaceholder = [self getFlagButton];
        [toolbarItems replaceObjectAtIndex:0 withObject:voteButtonPlaceholder];
        [toolbar setItems:toolbarItems animated:NO];    
    } else {
        voteButtonPlaceholder = [self getVoteButton];
        [toolbarItems replaceObjectAtIndex:0 withObject:voteButtonPlaceholder];
        [toolbar setItems:toolbarItems animated:NO];    
    }
    
    voteButtonPlaceholder.enabled = [self canVoteOnCurrentPhoto];
}

#pragma mark FlipButtons

- (void)infoButtonPressed:(id)sender
{
    if( [photoKeyList count] == 0 ) return;
    
    if(photoInfoView.view.superview == nil )
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        
        if( !photoInfoView )
            photoInfoView = [[PhotoInfoTableViewController alloc] init];

        photoInfoView.currentIndex = currentIndex;
        photoInfoView.date = [DateTimeUtil localDateStringFromUtcString:[dateList objectAtIndex:currentIndex]];
        
        [self.view addSubview:photoInfoView.view];
        
        [UIView commitAnimations];
        self.navigationItem.rightBarButtonItem.title = @"See Images";
        self.navigationItem.rightBarButtonItem.action = @selector(infoButtonPressed:);
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        
        self.currentIndex = photoInfoView.currentIndex;
        
        [photoInfoView.view removeFromSuperview];
        
        [UIView commitAnimations];
        self.navigationItem.rightBarButtonItem.title = @"See Map"; 
        self.navigationItem.rightBarButtonItem.action = @selector(showMap);
        [self scrollToCurrentIndex];
    }
}

- (void) showMap
{
    if( [photoKeyList count] == 0 ) return;
    
    if(mapView.view.superview == nil )
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        
        if( !mapView )
            mapView = [[AlternateViewController alloc] initWithIndex:currentIndex latList:latList lonList:lonList];
        mapView.currentIndex = currentIndex; //reduntant.  who cares...
        
        [self.view addSubview:mapView.view];
        [mapView viewDidAppear:YES];
        
        [UIView commitAnimations];
        self.navigationItem.rightBarButtonItem.title = @"See Images";
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        
        self.currentIndex = mapView.currentIndex;

        [mapView.view removeFromSuperview];
        [UIView commitAnimations];
        self.navigationItem.rightBarButtonItem.title = @"See Map";   
        [self scrollToCurrentIndex];
    }
}

#pragma mark ActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 )
    {
        [self voteImageUp];
    }
    if( buttonIndex == 1 )
    {
        [self flagPhoto];
    }
}

#pragma mark VoteImages
- (void) voteImageUp
{
    voteButtonPlaceholder = [ActivityButtonUtil createActivityIndicatorButton];
    [toolbarItems replaceObjectAtIndex:0 withObject:voteButtonPlaceholder];
    [toolbar setItems:toolbarItems];

    NSString *photoKey = [photoKeyList objectAtIndex:currentIndex];
    BOOL photoLiked = [[likedList objectAtIndex:currentIndex] caseInsensitiveCompare:@"True"] == NSOrderedSame;
    photoLiked = !photoLiked;

     TagImageViewController *controller = [controllerList objectAtIndex:currentIndex];
    controller.likedPhoto = photoLiked;
    
    NSString *newLikedStatus = photoLiked ? @"True" : @"False";
    [likedList replaceObjectAtIndex:currentIndex withObject:newLikedStatus];

   // [[controllerList objectAtIndex:currentIndex] showLikedMark:photoLiked];
    //voteButtonPlaceholder = [self getStarButton];
    
    [photoService likePhoto:photoKey like:photoLiked delegate:self didFinish:@selector(didLikePhoto:) didFail:@selector(didFail:)];
}

- (void) didLikePhoto:(NSDictionary*)dict
{
    BOOL photoLiked = [[likedList objectAtIndex:currentIndex] caseInsensitiveCompare:@"True"] == NSOrderedSame;
    
    voteButtonPlaceholder = photoLiked ? [self getStarButton] : [self getVoteButton];
    [toolbarItems replaceObjectAtIndex:0 withObject:voteButtonPlaceholder];
    [toolbar setItems:toolbarItems];
}

- (void) flagPhoto
{
    voteButtonPlaceholder = [ActivityButtonUtil createActivityIndicatorButton];
    [toolbarItems replaceObjectAtIndex:0 withObject:voteButtonPlaceholder];
    [toolbar setItems:toolbarItems];
    NSString *photoKey = [photoKeyList objectAtIndex:currentIndex];
    BOOL photoIsFlaggged = [[flaggedList objectAtIndex:currentIndex] caseInsensitiveCompare:@"True"] == NSOrderedSame;
    photoIsFlaggged = !photoIsFlaggged;
    
    TagImageViewController *controller = [controllerList objectAtIndex:currentIndex];
    controller.flaggedOffensive = photoIsFlaggged;
    
    NSString *newFlaggedStatus = photoIsFlaggged ? @"True" : @"False";
    [flaggedList replaceObjectAtIndex:currentIndex withObject:newFlaggedStatus];
    
    if( photoIsFlaggged )
    {
        [[controllerList objectAtIndex:currentIndex] showFlaggedPhoto];
    } 
    else 
    {
        [[controllerList objectAtIndex:currentIndex] showActualPhoto]; 
    }
    
    [photoService flagPhoto:photoKey flag:photoIsFlaggged delegate:self didFinish:@selector(didFlagPhoto:) didFail:@selector(didFail:)];
}

- (void) didFlagPhoto:(NSDictionary*)dict
{
    BOOL photoIsFlaggged = [[flaggedList objectAtIndex:currentIndex] caseInsensitiveCompare:@"True"] == NSOrderedSame;
    voteButtonPlaceholder = photoIsFlaggged ? [self getFlagButton] : [self getVoteButton]; 
    [toolbarItems replaceObjectAtIndex:0 withObject:voteButtonPlaceholder];
    [toolbar setItems:toolbarItems];
}


- (UIBarButtonItem*) getStarButton
{
    if( starButton == nil )
    {
        starButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonIconStar3.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(voteButtonPressed:)];
    }
    return starButton;
}

- (UIBarButtonItem*) getFlagButton
{
    if( flagButton == nil )
    {
        flagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonIconFlag3.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(voteButtonPressed:)];
    }
    return flagButton;    
}

- (UIBarButtonItem*) getVoteButton
{
    if( voteButton == nil )
    {
        voteButton = [[UIBarButtonItem alloc] initWithTitle:@"Vote" style:UIBarButtonItemStyleBordered target:self action:@selector(voteButtonPressed:)];
    }
    return voteButton;
}

- (void)dealloc {
    [controllerList release];
    [imageCounter release];
    
    [myScrollView release];
    [currentElement release];
    [voteButtonPlaceholder release];
    [imageCounter release];
    [photoKeyList release];
    [latList release];
    [lonList release];
    [flaggedList release];
    [likedList release];
    [canVoteList release];
    [tagKey release];
    
    [markService cancelReadRequests];
    [markService release];
    [photoService cancelReadRequests];
    [photoService release];
    
    [starButton release];
    [flagButton release];
    [voteButton release];
    
    [photoInfoView release];
    [mapView release];
    [dateList release];
    
    [toolbarItems release];
    [super dealloc];
}


@end
