//
//  AITacticWallAlways.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITWallAlways.h"
#import "NSArray+Functional.h"

@implementation AITWallAlways

-(AIAction *)suggestedAction:(AIGameState *)game {
    
    Spell * activeWall = game.activeWall;
    AIAction * action;
    
    if (game.isCooldown) return nil;
    
    if (activeWall == nil) {
        NSString * randomType = [self.walls randomItem];
        Spell * spell = [Spell fromType:randomType];
        
        if (self.reactionTime)
            action = [AIAction spell:spell time:(spell.castDelay+self.reactionTime) priority:5];
        else
            action = [AIAction spell:spell priority:5];
    }
    
    return action;
}


+(id)walls:(NSArray*)walls {
    AITWallAlways * tactic = [AITWallAlways new];
    tactic.walls = walls;
    return tactic;
}

+(id)walls:(NSArray*)walls reactionTime:(NSTimeInterval)reactionTime {
    AITWallAlways * tactic = [AITWallAlways new];
    tactic.walls = walls;
    tactic.reactionTime = reactionTime;
    return tactic;
}

@end
