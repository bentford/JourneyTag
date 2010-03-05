//
//  HelpViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 8/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController

- (id)initWithFile:(NSString*)filename
{
    self = [super init];
    myFilename = filename;
    
    return self;
}

- (void)viewDidLoad
{
    NSString *path = [[NSBundle mainBundle] pathForResource:myFilename ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [myWebView loadRequest:request];
    
    [super viewDidLoad];
}

- (IBAction)closeHelp:(id)sender
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end
