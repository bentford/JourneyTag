//
//  SecondTableViewController.m
//  JTTestHarness1
//
//  Created by Ben Ford on 8/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecondTableViewController.h"

@implementation SecondTableViewController

- (void)awakeFromNib
{
    UIImage *image = [UIImage imageNamed:@"TestPicture.jpg"];
    imageData = UIImageJPEGRepresentation(image, 0.3);
    [imageData retain];
    
    latList = [[NSArray alloc] initWithObjects: [NSNumber numberWithFloat:42.355901], [NSNumber numberWithFloat: 42.355901], nil];
    lonList = [[NSArray alloc] initWithObjects: [NSNumber numberWithFloat:-123.697748],  [NSNumber numberWithFloat:-122.717808], nil];
    
    [super awakeFromNib];
}

- (void)createBothAccounts
{
    [accountService createAccount:@"1234" username:@"testharnessaccount" password:@"hendrix" email:@"blargg27@gmail.com" delegate:self didFinish:nil didFail:@selector(didFail:)];        
    [accountService createAccount:@"1234" username:@"testharnessaccount2" password:@"hendrix" email:@"blargg27@gmail.com" delegate:self didFinish:nil didFail:@selector(didFail:)];        
}

- (void)runTestStructure
{
    [self createBothAccounts];
    
    titles = [[NSMutableArray alloc] initWithCapacity:0];
    [self updateTable:@"starting"];
    
    [accountService login:@"1234" username:@"testharnessaccount" password:@"hendrix" delegate:self didFinish:@selector(run2:) didFail:@selector(didFail:)];
}

- (void)run2:(NSDictionary*)dict
{
    accountKey = [dict valueForKey:@"accountKey"];
    if( [accountKey caseInsensitiveCompare:@"NotFound"] == NSOrderedSame ) 
    {
        [self updateTable:@"can't login"];
        return;
    } else 
        [self updateTable:@"login OK"];
    
    [accountService getAccountInfo:self didFinish:@selector(run2_1:) didFail:@selector(didFail:)];
}

- (void)run2_1:(NSDictionary*)dict
{
    [self updateTable:@"account info"];
   firstSet = [dict retain];
    
    [tagService create: @"TEST: Distance Test" destLat:20.9999 destLon:-120.0005 destinationAccuracy:5000 delegate:self didFinish:@selector(run3:) didFail:@selector(didFail:)];          
}

- (void)run3:(NSDictionary*)dict
{
    tagKey = [[dict valueForKey:@"tagKey"] retain];
    [self updateTable:@"created tag"];
    
    [tagService drop:tagKey imageData:imageData lat:[[latList objectAtIndex:0] doubleValue] lon:[[lonList objectAtIndex:0] doubleValue] delegate:self didFinish:@selector(run4:) didFail:@selector(didFail:)];
}

- (void)run4:(NSDictionary*)dict
{
    [self updateTable:@"dropped tag"];
    [accountService logout:self didFinish:@selector(run5:) didFail:@selector(didFail:)];
}

- (void)run5:(NSDictionary*)dict
{
    if( [(NSString*)[dict valueForKey:@"response"] compare:@"Done"] == NSOrderedSame )
        [self updateTable:@"logout OK"];
    else {
        [self updateTable:@"logout FAIL"];
        return;
    }
    
    [accountService login:@"1234" username:@"testharnessaccount2" password:@"hendrix" delegate:self didFinish:@selector(run6:) didFail:@selector(didFail:)];
}

- (void)run6:(NSDictionary*)dict
{
    [self updateTable:@"logged in"];
    [tagService pickup:tagKey delegate:self didFinish:@selector(run7:) didFail:@selector(didFail:)];
}

- (void)run7:(NSDictionary*)dict
{
    [self updateTable:@"picked up tag"];
    
    [tagService drop:tagKey imageData:imageData lat:[[latList objectAtIndex:1] doubleValue] lon:[[lonList objectAtIndex:1] doubleValue] delegate:self didFinish:@selector(run8:) didFail:@selector(didFail:)];
}

- (void) run8:(NSDictionary*)dict
{
    [self updateTable:@"dropped tag again"];
    [accountService logout:self didFinish:@selector(run9:) didFail:@selector(didFail:)];    
}

- (void) run9:(NSDictionary*)dict
{
    [self updateTable:@"logged out"];
    [accountService login:@"1234" username:@"testharnessaccount" password:@"hendrix" delegate:self didFinish:@selector(run10:) didFail:@selector(didFail:)];
}

- (void) run10:(NSDictionary*)dict
{
    [self updateTable:@"logged in"];
    [accountService getAccountInfo:self didFinish:@selector(run11:) didFail:@selector(didFail:)];
}

- (void)run11:(NSDictionary*)dict
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

