//
//  ScoreTestTableViewController.m
//  JTTestHarness1
//
//  Created by Ben Ford on 8/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ScoreTestTableViewController.h"


@implementation ScoreTestTableViewController

- (void)awakeFromNib
{
    UIImage *image = [UIImage imageNamed:@"TestPicture.jpg"];
    imageData = UIImageJPEGRepresentation(image, 0.3);
    [imageData retain];
    
    latList = [[NSArray alloc] initWithObjects: [NSNumber numberWithFloat:42.355901], [NSNumber numberWithFloat: 42.355901], nil];
    lonList = [[NSArray alloc] initWithObjects: [NSNumber numberWithFloat:-123.697748],  [NSNumber numberWithFloat:-122.717808], nil];
    
    accountName1 = @"testharnessaccount3";
    accountName2 = @"testharnessaccount";
    accountName3 = @"testharnessaccount2";
    
    [super awakeFromNib];
}

- (void)createAllAccounts
{
    [accountService createAccount:@"1234" username:accountName1 password:@"hendrix" email:@"blargg27@gmail.com" delegate:self didFinish:nil didFail:@selector(didFail:)];        
    [accountService createAccount:@"1234" username:accountName2 password:@"hendrix" email:@"blargg27@gmail.com" delegate:self didFinish:nil didFail:@selector(didFail:)];        
    [accountService createAccount:@"1234" username:accountName3 password:@"hendrix" email:@"blargg27@gmail.com" delegate:self didFinish:nil didFail:@selector(didFail:)];        
}

- (void)runTestStructure
{
    [self createAllAccounts];
    
    titles = [[NSMutableArray alloc] initWithCapacity:0];
    [self updateTable:@"starting"];
    
    [accountService login:@"1234" username:accountName2 password:@"hendrix" delegate:self didFinish:@selector(run2:) didFail:@selector(didFail:)];
}

- (void)run2:(NSDictionary*)dict
{
    [self updateTable:@"login as #2"];
    [tagService create: @"TEST: Distance Test" destLat:[[latList objectAtIndex:1]doubleValue] destLon:[[lonList objectAtIndex:1]doubleValue] destinationAccuracy:5000 delegate:self didFinish:@selector(run3:) didFail:@selector(didFail:)];          
}

- (void)run3:(NSDictionary*)dict
{
    tagKey2 = [[dict valueForKey:@"tagKey"] retain];
    [self updateTable:@"create #2 tag"];
    
    [tagService drop:tagKey2 imageData:imageData lat:[[latList objectAtIndex:0] doubleValue] lon:[[lonList objectAtIndex:0] doubleValue] delegate:self didFinish:@selector(run4:) didFail:@selector(didFail:)];
}

- (void)run4:(NSDictionary*)dict
{
    [self updateTable:@"dropped #2 tag"];
    [accountService logout:self didFinish:@selector(run5:) didFail:@selector(didFail:)];
}

- (void)run5:(NSDictionary*)dict
{
    [self updateTable:@"logout as #2"];
    [accountService login:@"1234" username:accountName3 password:@"hendrix" delegate:self didFinish:@selector(run6:) didFail:@selector(didFail:)];
}

- (void)run6:(NSDictionary*)dict
{
    [self updateTable:@"Login as #3"];
    [tagService create: @"TEST: Distance Test" destLat:[[latList objectAtIndex:1]doubleValue] destLon:[[lonList objectAtIndex:1]doubleValue] destinationAccuracy:5000 delegate:self didFinish:@selector(run7:) didFail:@selector(didFail:)];
}

- (void)run7:(NSDictionary*)dict
{
    tagKey3 = [[dict valueForKey:@"tagKey"] retain];
    [self updateTable:@"create #3 tag"];
    
    [tagService drop:tagKey3 imageData:imageData lat:[[latList objectAtIndex:0] doubleValue] lon:[[lonList objectAtIndex:0] doubleValue] delegate:self didFinish:@selector(run8:) didFail:@selector(didFail:)];
}

- (void)run8:(NSDictionary*)dict
{
    [self updateTable:@"dropped #3 tag"];
    [accountService logout:self didFinish:@selector(run9:) didFail:@selector(didFail:)];
}

- (void)run9:(NSDictionary*)dict
{
    [self updateTable:@"logout as #3"];
    [accountService login:@"1234" username:accountName1 password:@"hendrix" delegate:self didFinish:@selector(run10:) didFail:@selector(didFail:)];
}

- (void)run10:(NSDictionary*)dict
{
    [self updateTable:@"Login as #1"];
    [accountService getAccountInfo:self didFinish:@selector(run11:) didFail:@selector(didFail:)];
}

- (void)run11:(NSDictionary*)dict
{
    [self updateTable:@"account info"];
    firstSet = [dict retain];
    
    [tagService pickup:tagKey2 delegate:self didFinish:@selector(run12:) didFail:@selector(didFail:)];
}

- (void)run12:(NSDictionary*)dict
{
    [self updateTable:@"pickup #2 tag"];
    [tagService pickup:tagKey3 delegate:self didFinish:@selector(run13:) didFail:@selector(didFail:)];
}

- (void)run13:(NSDictionary*)dict
{
    [self updateTable:@"pickup #3 tag"];
    [tagService drop:tagKey2 imageData:imageData lat:[[latList objectAtIndex:1] doubleValue] lon:[[lonList objectAtIndex:1] doubleValue] delegate:self didFinish:@selector(run14:) didFail:@selector(didFail:)];    
}

- (void)run14:(NSDictionary*)dict
{
    [self updateTable:@"drop #2 tag"];
    [tagService drop:tagKey3 imageData:imageData lat:[[latList objectAtIndex:1] doubleValue] lon:[[lonList objectAtIndex:1] doubleValue] delegate:self didFinish:@selector(run15:) didFail:@selector(didFail:)];    
}

- (void)run15:(NSDictionary*)dict
{
    [self updateTable:@"drop #3 tag"];
    [accountService logout:self didFinish:@selector(run16:) didFail:@selector(didFail:)];
}

- (void)run16:(NSDictionary*)dict
{
    [self updateTable:@"logout"];
    [accountService login:@"1234" username:accountName2 password:@"hendrix" delegate:self didFinish:@selector(run17:) didFail:@selector(didFail:)];
}

- (void)run17:(NSDictionary*)dict
{
    [self updateTable:@"login #2"];   
    [markService getAllForTag:tagKey2 delegate:self didFinish:@selector(run18:) didFail:@selector(didFail:)];
}

- (void)run18:(NSDictionary*)dict
{      
    [self updateTable:@"fetched marks"];
    NSArray *marks = [dict valueForKey:@"marks"];
    NSDictionary *mark = [marks objectAtIndex:0];
    NSString *photoKey = [mark valueForKey:@"photoKey"];
    [photoService likePhoto:photoKey like:YES delegate:self didFinish:@selector(run19:) didFail:@selector(didFail:)];
}

- (void)run19:(NSDictionary*)dict
{
    [self updateTable:@"liked photo"];
    [accountService logout:self didFinish:@selector(run20:) didFail:@selector(didFail:)];
}


- (void)run20:(NSDictionary*)dict
{
    [self updateTable:@"logout"];
    [accountService login:@"1234" username:accountName3 password:@"hendrix" delegate:self didFinish:@selector(run21:) didFail:@selector(didFail:)];
}

- (void)run21:(NSDictionary*)dict
{
    [self updateTable:@"login #2"];   
    [markService getAllForTag:tagKey3 delegate:self didFinish:@selector(run22:) didFail:@selector(didFail:)];
}

- (void)run22:(NSDictionary*)dict
{      
    [self updateTable:@"fetched marks"];
    NSArray *marks = [dict valueForKey:@"marks"];
    NSDictionary *mark = [marks objectAtIndex:0];
    NSString *photoKey = [mark valueForKey:@"photoKey"];
    [photoService likePhoto:photoKey like:YES delegate:self didFinish:@selector(run23:) didFail:@selector(didFail:)];
}

- (void)run23:(NSDictionary*)dict
{
    [self updateTable:@"liked photo"];
    [accountService logout:self didFinish:@selector(run24:) didFail:@selector(didFail:)];
}


- (void)run24:(NSDictionary*)dict
{
    [self updateTable:@"logged out"];   
    [accountService login:@"1234" username:accountName1 password:@"hendrix" delegate:self didFinish:@selector(run25:) didFail:@selector(didFail:)];
}

- (void)run25:(NSDictionary*)dict
{
    [self updateTable:@"login #1"];
    [accountService getAccountInfo:self didFinish:@selector(run26:) didFail:@selector(didFail:)];    
}

- (void)run26:(NSDictionary*)dict
{
    [self updateTable:@"account info"];
    secondSet = [dict retain];
    
    [self compareAccountInfoChanges];    
}

- (void)compareAccountInfoChanges
{
    int traveled = [[firstSet valueForKey:@"totalDistanceTraveled"] intValue];
    int traveled2 = [[secondSet valueForKey:@"totalDistanceTraveled"] intValue];
    int delta = traveled2 - traveled;
    
    NSString *result = [[NSString alloc] initWithFormat:@"traveled: %d", delta];
    [self updateTable:result];
    [result release];
    
    if( delta == 0 )
        [self updateTable:@"OK"];
    else 
        [self updateTable:@"FAIL"];
    
    int carried = [[firstSet valueForKey:@"totalDistanceCarried"] intValue];
    int carried2 = [[secondSet valueForKey:@"totalDistanceCarried"] intValue];
    delta = carried2 - carried;
    result = [[NSString alloc] initWithFormat:@"carried: %d", delta];
    [self updateTable:result];
    [result release];
    
    if( delta == 100 )
        [self updateTable:@"OK"];
    else 
        [self updateTable:@"FAIL"];
    
    int arriveScore = [[firstSet valueForKey:@"arriveScore"] intValue];
    int arriveScore2 = [[secondSet valueForKey:@"arriveScore"] intValue];
    delta = arriveScore2 - arriveScore;
    result = [[NSString alloc] initWithFormat:@"arrive score: %d", delta];
    [self updateTable:result];
    [result release];
    if( delta == 30 )
        [self updateTable:@"OK"];
    else
        [self updateTable:@"FAIL"];
    
    int photoScore = [[firstSet valueForKey:@"photoScore"] intValue];
    int photoScore2 = [[secondSet valueForKey:@"photoScore"] intValue];
    delta = photoScore2 - photoScore;
    result = [[NSString alloc] initWithFormat:@"photo score: %d", delta];
    [self updateTable:result];
    [result release];
    
    if( delta == 200 )
        [self updateTable:@"OK"];
    else
        [self updateTable:@"FAIL"];
}



- (void)didFail:(ASIHTTPRequest*)request
{
    [self updateTable:@"failed"];
}



- (void)dealloc {
    [super dealloc];
}


@end

