//
//  AITacticWallRenew.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITWallRenew.h"

@interface AITWallRenew ()
@property (nonatomic, strong) NSString * wallType;
@end

@implementation AITWallRenew
-(AIAction *)suggestedAction:(AIGameState *)game {
    
    Spell * activeWall = game.activeWall;
    
    if (activeWall)
        self.wallType = activeWall.type;
    
    if (game.isCooldown) return nil;
    
    if (self.wallType && ((self.createIfDead && activeWall == nil) || activeWall.strength == 1)) {
        Spell * spell = [Spell fromType:self.wallType];
        return [AIAction spell:spell];
    }
    
    return nil;
}

+(id)createIfDead {
    AITWallRenew * tactic = [AITWallRenew new];
    tactic.createIfDead = YES;
    return tactic;
}

@end
