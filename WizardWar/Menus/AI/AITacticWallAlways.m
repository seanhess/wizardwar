//
//  AITacticWallAlways.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITacticWallAlways.h"
#import "NSArray+Functional.h"

@implementation AITacticWallAlways

-(AIAction *)suggestedAction:(AIGameState *)game {
    
    Spell * activeWall = game.activeWall;
    AIAction * action;
    
    if (game.isCooldown) return nil;
    
    if (activeWall == nil) {
        NSString * randomType = [self.walls randomItem];
        Spell * spell = [Spell fromType:randomType];
        action = [AIAction spell:spell priority:5];
    }
    
    return action;
}


+(id)walls:(NSArray*)walls {
    AITacticWallAlways * tactic = [AITacticWallAlways new];
    tactic.walls = walls;
    return tactic;
}
@end
