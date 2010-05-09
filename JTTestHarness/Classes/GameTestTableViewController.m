//
//  GameTestTableViewController.m
//  JTTestHarness1
//
//  Created by Ben Ford on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameTestTableViewController.h"
#import "JTGameService.h"

@implementation GameTestTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    gameService = [[JTGameService alloc] init];
    
}

- (void)runTestStructure {
    [gameService getAccountsByHighScoreWithDelegate:self didFinish:@selector(run1:) didFail:@selector(didFail:)];
}

- (void)run1:(NSDictionary *)data {
    NSArray *accounts = [data objectForKey:@"accounts"];
    [self updateTable:[NSString stringWithFormat:@"fetched %d scores", [accounts count]]];
    [gameService getLastTenPhotosWithDelegate:self didFinish:@selector(run2:) didFail:@selector(didFail:)];
}

- (void)run2:(NSDictionary *)data {
    NSArray *photos = [data objectForKey:@"photoKeys"];
    
    [self updateTable:[NSString stringWithFormat:@"fetched %d photos", [photos count]]];
}

- (void)didFail:(ASIHTTPRequest *)request {
    
}

- (void)dealloc {
    [gameService release];
    
    [super dealloc];
}


@end

