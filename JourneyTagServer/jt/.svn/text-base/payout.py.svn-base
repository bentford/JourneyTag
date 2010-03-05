import logging
import jt.gamesettings

class jtPayout:
    @staticmethod
    def increaseBy(level):
        if level is 0:
            return 0
        return (level * jt.gamesettings.levelSeed) - jt.gamesettings.levelSeed

    @staticmethod
    def calculateLevel(carryScore):
        level = jt.gamesettings.startLevel
        levelScore = jt.gamesettings.startScore
        while levelScore <= carryScore:
            level += 1
            levelScore += jtPayout.increaseBy(level)

        return level-1
    
    @staticmethod
    def calculatePayout(carryScore):
        level = jtPayout.calculateLevel(carryScore)
        payout = 1 + (jt.gamesettings.payoutMultiplier * level) - jt.gamesettings.payoutMultiplier
        return round(payout,3)
    
    @staticmethod
    def pointsForLevel(level):
        totalPoints = 0
        for curLevel in range(level+1): #remember: range excludes highest number
            totalPoints += jtPayout.increaseBy(curLevel)
        return totalPoints
        