//
//  QuestLevel.m
//  WizardWar
//
//  Created by Sean Hess on 8/23/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "QuestLevel.h"
#import "AIOpponent.h"

@implementation QuestLevel
@synthesize AIType = _AIType;
@synthesize colorRGB = _colorRGB;
@synthesize tactics = _tactics;

@dynamic name;
@dynamic gamesTotal;
@dynamic gamesWins;
@dynamic level;
@dynamic passed;
@dynamic wizardLevel;

- (CGFloat)progress {
    return ((float)self.gamesWins / (float)self.masteryWins);
}

// problem is
//-(NSInteger)masteryWins {
//    return self.gamesLosses + 2; // you have to win 2 times + the number of times you've lost
//}

-(NSInteger)masteryWins {
    return 4;
}

- (NSInteger)gamesLosses {
    return self.gamesTotal - self.gamesWins;
}

- (BOOL)isMastered {
    return self.progress >= 1.0;
}

- (BOOL)hasAttempted {
    return self.gamesTotal > 0;
}

- (id<AIService>)ai {
    if (self.AIType)
        return [self.AIType new];
    
    else {
        return [[AIOpponent alloc] initWithName:self.name color:self.colorRGB tactics:self.tactics];
    }
}

@end
