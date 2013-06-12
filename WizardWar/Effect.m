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
    }
    return self;
}

-(void)start {}

-(SpellInteraction*)interactPlayer:(Player*)player spell:(Spell*)spell {
    player.health -= spell.damage;
    if (spell.damage > 0)
        [player setState:PlayerStateHit animated:YES];
    
    return [SpellInteraction cancel];
}

-(void)playerDidCastSpell:(Player*)player {

}

@end
