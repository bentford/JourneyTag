//
//  JTPayoutUtility.h
//  JourneyTag
//
//  Created by Ben Ford on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JTPayoutUtility : NSObject {
    NSInteger levelSeed;
    float payoutMultiplier;
    NSInteger startLevel;
    NSInteger startScore;
}

- (id)init;
- (NSMutableArray*) generateLevelScores:(NSUInteger)length;
- (NSInteger)amountToIncreaseForLevel:(NSInteger)level;

- (NSInteger)calculateLevelForCarryScore:(NSInteger)carryScore;
- (float)calculatePayoutForCarryScore:(NSInteger)carryScore;
- (NSInteger)pointsForLevel:(NSInteger)level;

@end