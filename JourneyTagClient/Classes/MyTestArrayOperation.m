//
//  MyTestArrayOperation.m
//  JourneyTag
//
//  Created by Ben Ford on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyTestArrayOperation.h"


@implementation MyTestArrayOperation

- (id) initWithArray:(NSMutableArray*)array delegate:(id)delegate readyToDisplay:(SEL)readyToDisplay
{
    self = [super init];
    myArray = [array retain];
    readyToDisplaySelector = readyToDisplay;
    myDelegate = [delegate retain];
    return self;
}

- (void)main
{
    JTPayoutUtility *payoutUtil = [[JTPayoutUtility alloc] init];
    int count = [myArray count];
    int previous = 0;
    for(int index = 0; index < count; index++ )
    {
        int current = [payoutUtil amountToIncreaseForLevel:index] + previous;
        NSString *rowText = [[NSString alloc] initWithFormat:@"Level %d - %d points",index, current];
        @synchronized(myArray)
        {
            [myArray replaceObjectAtIndex:index withObject:rowText];
            [rowText release];
        }
        previous = current;
        
        if( index == 2 && readyToDisplaySelector && myDelegate && [myDelegate respondsToSelector:readyToDisplaySelector])
        {
            [myDelegate performSelectorOnMainThread:readyToDisplaySelector withObject:nil waitUntilDone:[NSThread isMainThread]];		
        }
    }
    [payoutUtil release];
}

- (void)dealloc
{
    [myArray release];
    [myDelegate release];
    [super dealloc];
}
@end
