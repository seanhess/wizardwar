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

-(SpellInteraction*)interactPlayer:(Player*)player spell:(Spell*)spell {
    player.health -= spell.damage;
    if (spell.damage > 0)
        [player setState:PlayerStateHit animated:YES];
    
    return [SpellInteraction cancel];
}

-(void)playerDidCastSpell:(Player*)player {
    player.effect = nil;
}

@end
