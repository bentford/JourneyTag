//
//  TagHistoryViewController.h
//  JourneyTag1
//
//  Created by Ben Ford on 4/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagImageViewController.h"
#import "AlternateViewController.h"
#import "JTMarkService.h"
#import "JTPhotoService.h"
#import "PhotoInfoTableViewController.h"

@interface TagHistoryViewController : UIViewController 
<UIActionSheetDelegate, UIAlertViewDelegate>
{
    UIScrollView *myScrollView;
    
    NSString *currentElement;
    NSMutableArray *controllerList;
    AlternateViewController *mapView;    

    NSInteger currentIndex;
    
    IBOutlet UIToolbar *toolbar;
    NSMutableArray *toolbarItems;
    UIBarButtonItem *voteButtonPlaceholder;
    UIBarButtonItem *imageCounter;
    
    NSMutableArray *photoKeyList;
    NSMutableArray *latList;
    NSMutableArray *lonList;
    NSMutableArray *flaggedList;
    NSMutableArray *likedList;
    NSMutableArray *canVoteList;
    NSMutableArray *dateList;
    
    NSString *tagKey;
    
    JTMarkService *markService;
    JTPhotoService *photoService;
    
    BOOL canVote;
    
    UIBarButtonItem *starButton;
    UIBarButtonItem *flagButton;
    UIBarButtonItem *voteButton;
    
    PhotoInfoTableViewController *photoInfoView;
}
@property (nonatomic, retain) NSString *tagKey;
@property (nonatomic,retain) IBOutlet UIScrollView *myScrollView;
@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSMutableArray *controllerList;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, retain) AlternateViewController *mapView;
@property (nonatomic) BOOL canVote;

-(void)loadPage:(int)pageNumber;
- (void)loadMarksForTag;
- (void)scrollViewDidScroll:(UIScrollView*)scrollView;
- (void) showMap;
- (void) updateImageCounter:(NSInteger)imageIndex;
- (void) scrollToCurrentIndex;

- (void) setupScrollView;
- (void) addToScrollView:(TagImageViewController*)controller pageNumber:(int)pageNumber;
- (void) releasePage:(int)pageNumber;

- (IBAction) voteButtonPressed:(id)sender;
- (void) flagPhoto;
- (void) didFlagPhoto:(NSDictionary*)dict;
- (void) voteImageUp;

- (UIBarButtonItem*) getStarButton;
- (UIBarButtonItem*) getFlagButton;
- (UIBarButtonItem*) getVoteButton;
- (void) updateVoteButton:(TagImageViewController*)controller;
- (BOOL)canVoteOnCurrentPhoto;
@end
