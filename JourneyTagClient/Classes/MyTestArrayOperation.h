//
//  MyTestArrayOperation.h
//  JourneyTag
//
//  Created by Ben Ford on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTPayoutUtility.h"

@interface MyTestArrayOperation : NSOperation {
    NSMutableArray *myArray;
    SEL readyToDisplaySelector;
    id myDelegate;
}
- (id) initWithArray:(NSMutableArray*)array delegate:(id)delegate readyToDisplay:(SEL)readyToDisplay;

@end
