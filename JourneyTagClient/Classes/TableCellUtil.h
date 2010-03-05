//
//  TableCellUtil.h
//  JourneyTag
//
//  Created by Ben Ford on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TableCellUtil : NSObject {

}

+ (void) setupLabeledCell:(UITableViewCell*)cell labelText:(NSString*)labelText valueText:(NSString*)valueText;

+ (void)setupTextBoxCell:(UITableViewCell*)cell valueText:(NSString*)valueText;
+ (void)setupTextBoxCell:(UITableViewCell*)cell valueText:(NSString*)valueText height:(NSInteger)height;

+ (void)setupWebViewCell:(UITableViewCell*)cell filename:(NSString*)filename height:(NSInteger)height;

+ (UIFont*)valueFont;
+ (UIFont*)labelFont;

@end
