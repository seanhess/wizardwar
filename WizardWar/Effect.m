//
//  Effect.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Effect.h"
#import "Spell.h"
#import "Wizard.h"

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

-(void)start:(NSInteger)tick player:(Wizard *)player {
    self.startTick = tick;
}

-(void)cancel:(Wizard*)player {
    player.effect = nil;
}

// the default effect is to damage the player and cancel the spell
-(SpellInteraction*)interactPlayer:(Wizard*)player spell:(Spell*)spell currentTick:(NSInteger)currentTick {
    player.health -= spell.damage;
    
    if (spell.damage > 0)
        [player setState:PlayerStateHit animated:YES];
    
    if (player.effect.cancelsOnHit)
        [player.effect cancel:player];
    
    return [SpellInteraction cancel];
}

-(SpellInteraction*)interactSpell:(Spell*)spell {
    return [SpellInteraction nothing];
}

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard*)player {
    
}

@end
