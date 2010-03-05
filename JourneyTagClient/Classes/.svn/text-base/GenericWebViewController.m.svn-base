//
//  AboutAppViewController.m
//  JourneyTag
//
//  Created by Ben Ford on 8/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GenericWebViewController.h"


@implementation GenericWebViewController

- (id)initWithFilename:(NSString*)filename
{
    self = [super init];
    myFilename = [filename retain];
    return self;
}

- (void)viewDidLoad 
{    
    myWebView.delegate = self;
    NSString *path = [[NSBundle mainBundle] pathForResource:myFilename ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [myWebView loadRequest:request];
    [super viewDidLoad];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL useThisWindow = YES;
    NSURL *url = [request URL];
    if( ( [[url scheme] isEqualToString: @"http"] || [[url scheme] isEqualToString: @"https"])  
        && navigationType == UIWebViewNavigationTypeLinkClicked ) 
    {  
        useThisWindow = NO;
        [[UIApplication sharedApplication] openURL:url];  
    }  
    return useThisWindow;
}
- (void)dealloc 
{
    [myFilename release];
    [super dealloc];
}


@end
