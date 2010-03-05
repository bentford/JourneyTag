//
//  JTPayoutUtility.m
//  JourneyTag
//
//  Created by Ben Ford on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JTPayoutUtility.h"


@implementation JTPayoutUtility
- (id)init
{
    self = [super init];
    levelSeed = 500;
    payoutMultiplier = 0.15;
    startLevel = 1;
    startScore = 0;
    return self;
}

- (NSArray*) generateLevelScores:(NSUInteger)length
{
    NSMutableArray *levelScores = [[[NSMutableArray alloc] initWithCapacity:length] autorelease];
    
    int previous = 0;
    for(int i = startLevel; i <= length; i++ )
    {
        NSInteger current = [self amountToIncreaseForLevel:i] + previous;
        NSNumber *number = [[NSNumber alloc] initWithInt:current];
        [levelScores addObject:number];
        [number release];
        
        previous = current;
    }
    return levelScores;
}

- (NSInteger)amountToIncreaseForLevel:(NSInteger)level
{
    if( level == 0 )
        return 0;
    
    return (level * levelSeed) - levelSeed;
}

- (NSInteger)calculateLevelForCarryScore:(NSInteger)carryScore
{
    NSUInteger level = startLevel;
    NSUInteger levelScore = startScore;
    while (levelScore <= carryScore)
    {
        level += 1;
        levelScore += [self amountToIncreaseForLevel:level];
    }
    return level-1;
}

- (float)calculatePayoutForCarryScore:(NSInteger)carryScore
{
    NSUInteger level = [self calculateLevelForCarryScore:carryScore];
    return 1.0 + (payoutMultiplier * (float)level) - payoutMultiplier;
}

- (NSInteger)pointsForLevel:(NSInteger)level
{
    NSInteger totalPoints = 0;
    for(int i = startLevel; i <= level; i++ )
    {
        totalPoints += [self amountToIncreaseForLevel:i];
    }
    return totalPoints;   
}

@end


