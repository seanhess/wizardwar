//
//  Effect.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Effect.h"
#import "Spell.h"
#import "Player.h"

@implementation Effect

-(id)init {
    self = [super init];
    if (self) {
        self.active = YES;
        self.delay = 0;
        self.duration = EFFECT_INDEFINITE;
    }
    return self;
}

-(void)start:(NSInteger)tick player:(Player *)player {
    self.startTick = tick;
}

-(void)cancel:(Player*)player {
    player.effect = nil;
}

// the default effect is to damage the player and cancel the spell
-(SpellInteraction*)interactPlayer:(Player*)player spell:(Spell*)spell {
    player.health -= spell.damage;
    
    if (spell.damage > 0)
        [player setState:PlayerStateHit animated:YES];
    
    if (player.effect.cancelsOnHit)
        [player.effect cancel:player];
    
    return [SpellInteraction cancel];
}

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Player*)player {
    
}

@end
