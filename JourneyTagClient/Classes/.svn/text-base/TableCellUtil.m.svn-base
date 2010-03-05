//
//  TableCellUtil.m
//  JourneyTag
//
//  Created by Ben Ford on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableCellUtil.h"


@implementation TableCellUtil

+ (void) setupCustomCell:(UITableViewCell*)cell labelText:(NSString*)labelText valueText:(NSString*)valueText
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 70, 25)];
    label.textAlignment = UITextAlignmentRight;
    label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]-5];
    label.text = labelText;
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 190, 25)];
    text.textAlignment = UITextAlignmentLeft;
    text.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    text.text = valueText;
    
    [cell.contentView addSubview:label];
    [cell.contentView addSubview:text];
    
    [label release];
    [text release];
}

+ (void) setupMediumLabeledCustomCell:(UITableViewCell*)cell labelText:(NSString*)labelText valueText:(NSString*)valueText
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 120, 25)];
    label.textAlignment = UITextAlignmentRight;
    label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]-5];
    label.text = labelText;
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, 130, 25)];
    text.textAlignment = UITextAlignmentLeft;
    text.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    text.text = valueText;
    
    [cell.contentView addSubview:label];
    [cell.contentView addSubview:text];
    
    [label release];
    [text release];
}

+ (void) setupMediumLabeledCell2:(UITableViewCell*)cell labelText:(NSString*)labelText valueText:(NSString*)valueText
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 90, 25)];
    label.textAlignment = UITextAlignmentRight;
    label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]-5];
    label.text = labelText;
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 90, 25)];
    text.textAlignment = UITextAlignmentLeft;
    text.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    text.text = valueText;
    
    [cell.contentView addSubview:label];
    [cell.contentView addSubview:text];
    
    [label release];
    [text release];
}

+ (void)setupTextBoxCell:(UITableViewCell*)cell valueText:(NSString*)valueText
{
    UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 150)];
    
    mainLabel.text = valueText;
    mainLabel.numberOfLines = 0;
    
    [cell.contentView addSubview:mainLabel];
    [mainLabel release];
}

+ (void)setupTextBoxCell:(UITableViewCell*)cell valueText:(NSString*)valueText height:(NSInteger)height
{
    UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, height)];
    
    mainLabel.text = valueText;
    mainLabel.numberOfLines = 0;
    
    [cell.contentView addSubview:mainLabel];
    [mainLabel release];    
}

+ (UIFont*)valueFont
{
    return [UIFont systemFontOfSize:[UIFont labelFontSize]];
}
+ (UIFont*)labelFont
{
    return [UIFont boldSystemFontOfSize:[UIFont labelFontSize]-5];
}

+ (void)setupWebViewCell:(UITableViewCell*)cell filename:(NSString*)filename height:(NSInteger)height
{
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(10, 0, 280, height)];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [web loadRequest:request];
    
    [cell.contentView addSubview:web];
    [web release];
}

@end
