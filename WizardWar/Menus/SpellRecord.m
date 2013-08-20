//
//  SpellRecord.m
//  WizardWar
//
//  Created by Sean Hess on 8/19/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellRecord.h"


@implementation SpellRecord

@dynamic type;
@dynamic name;
@dynamic castTotal;
@dynamic castUniqueMatches;

-(SpellbookLevel)level {
    if (self.castUniqueMatches < 1) return SpellbookLevelNone;
    else if (self.castUniqueMatches < 5) return SpellbookLevelNovice;
    else if (self.castUniqueMatches < 15) return SpellbookLevelAdept;
    else return SpellbookLevelMaster;
}

-(NSInteger)targetForLevel:(SpellbookLevel)level {
    if (level == SpellbookLevelNone) return 0;
    else if (level == SpellbookLevelNovice) return 1;
    else if (level == SpellbookLevelAdept) return 5;
    else if (level == SpellbookLevelMaster) return 15;
    else return 100;
}

// Should show the progress from the previous target to the next one
-(CGFloat)progress {
    return ((float)self.castUniqueMatches) / [self targetForLevel:SpellbookLevelMaster];
//    NSInteger target = [self targetForLevel:self.level];
//    NSInteger start = [self targetForLevel:self.level-1];
//    
//    float past = self.castUniqueMatches - start;
//    float goal = target - start;
//    
//    return (past/goal);
}

- (BOOL)isUnlocked {
    return (self.level >= SpellbookLevelAdept);
}

- (BOOL)isDiscovered {
    return (self.level >= SpellbookLevelNovice);
}

@end
