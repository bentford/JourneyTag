//
//  TravelScoreTableViewController.m
//  JTTestHarness1
//
//  Created by Ben Ford on 8/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CarryScoreTableViewController.h"


@implementation CarryScoreTableViewController

- (void)awakeFromNib
{
    UIImage *image = [UIImage imageNamed:@"TestPicture.jpg"];
    imageData = UIImageJPEGRepresentation(image, 0.3);
    [imageData retain];
    
    latList = [[NSArray alloc] initWithObjects: [NSNumber numberWithFloat:42.355901], [NSNumber numberWithFloat: 42.355901], nil];
    lonList = [[NSArray alloc] initWithObjects: [NSNumber numberWithFloat:-123.697748],  [NSNumber numberWithFloat:-122.717808], nil];

    accountName1 = @"testharnessaccount";
    accountName2 = @"testharnessaccount2";
    accountName3 = @"testharnessaccount3";
    
    [super awakeFromNib];
}

- (void)createAllAccounts
{
    [accountService createAccount:@"1234" username:accountName1 password:@"hendrix" email:@"blargg27@gmail.com" delegate:self didFinish:nil didFail:@selector(didFail:)];        
    [accountService createAccount:@"1234" username:accountName2 password:@"hendrix" email:@"blargg27@gmail.com" delegate:self didFinish:nil didFail:@selector(didFail:)];        
    //[accountService createAccount:@"1234" username:accountName3 password:@"hendrix" email:@"blargg27@gmail.com" delegate:self didFinish:nil didFail:@selector(didFail:)];        
}

- (void)runTestStructure
{
    [self createAllAccounts];
    
    titles = [[NSMutableArray alloc] initWithCapacity:0];
    [self updateTable:@"starting"];
    
    [accountService login:@"1234" username:accountName1 password:@"hendrix" delegate:self didFinish:@selector(run2:) didFail:@selector(didFail:)];
}

- (void)run2:(NSDictionary*)dict
{
    [self updateTable:@"Login as #1"];
    [accountService getAccountInfo:self didFinish:@selector(run3:) didFail:@selector(didFail:)];
}

- (void)run3:(NSDictionary*)dict
{
    [self updateTable:@"account info"];
    firstSet = [dict retain];

    [accountService logout:self didFinish:@selector(run4:) didFail:@selector(didFail:)];
}

- (void)run4:(NSDictionary*)dict
{
    [self updateTable:@"logout as #1"];
    [accountService login:@"1234" username:accountName2 password:@"hendrix" delegate:self didFinish:@selector(run5:) didFail:@selector(didFail:)];
}

- (void)run5:(NSDictionary*)dict
{
    [self updateTable:@"login as #2"];
    [tagService create: @"TEST: Distance Test" destLat:20.9999 destLon:-120.0005 destinationAccuracy:5000 delegate:self didFinish:@selector(run6:) didFail:@selector(didFail:)];          
}

- (void)run6:(NSDictionary*)dict
{
    tagKey = [[dict valueForKey:@"tagKey"] retain];
    [self updateTable:@"create #2 tag"];
    
    [tagService drop:tagKey imageData:imageData lat:[[latList objectAtIndex:0] doubleValue] lon:[[lonList objectAtIndex:0] doubleValue] delegate:self didFinish:@selector(run7:) didFail:@selector(didFail:)];
}

- (void)run7:(NSDictionary*)dict
{
    [self updateTable:@"dropped #2 tag"];
    [accountService logout:self didFinish:@selector(run8:) didFail:@selector(didFail:)];
}

- (void)run8:(NSDictionary*)dict
{
    [self updateTable:@"logout as #2"];
    [accountService login:@"1234" username:accountName1 password:@"hendrix" delegate:self didFinish:@selector(run9:) didFail:@selector(didFail:)];
}

- (void)run9:(NSDictionary*)dict
{
    [self updateTable:@"login as #1"];
    [tagService pickup:tagKey delegate:self didFinish:@selector(run10:) didFail:@selector(didFail:)];
}

- (void)run10:(NSDictionary*)dict
{
    [self updateTable:@"pickup #2 tag"];
    [tagService drop:tagKey imageData:imageData lat:[[latList objectAtIndex:1] doubleValue] lon:[[lonList objectAtIndex:1] doubleValue] delegate:self didFinish:@selector(run11:) didFail:@selector(didFail:)];    
}

- (void)run11:(NSDictionary*)dict
{
    [self updateTable:@"drop #2 tag"];
    [accountService getAccountInfo:self didFinish:@selector(run12:) didFail:@selector(didFail:)];
}

- (void)run12:(NSDictionary*)dict
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
    
    if( delta == 50 )
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

