//
//  QuestLevel.m
//  WizardWar
//
//  Created by Sean Hess on 8/23/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "QuestLevel.h"


@implementation QuestLevel

@dynamic name;
@dynamic gamesTotal;
@dynamic gamesWins;
@dynamic level;
@dynamic passed;

- (CGFloat)progress {
    return ((float)self.gamesWins / (float)self.masteryWins);
}

-(NSInteger)masteryWins {
    return self.gamesLosses + 2; // you have to win 2 times + the number of times you've lost
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

@end
