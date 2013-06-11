//
//  SpellInvisibility.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellInvisibility.h"
#import "EffectInvisible.h"

@implementation SpellInvisibility

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.damage = 0;
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    return [SpellInteraction nothing];
}

// interaction between invisibility spell and player
// I need a place where I can check to see if it was invisibility or not
// well, I need the player to have a spell effect no?
// that way the Spell can handle the interaction
-(SpellInteraction *)interactPlayer:(Player *)player {
    
    // TODO make this happen SLOWLY
    // need to remove the effect when the player next casts a spell
    Effect * effect = [EffectInvisible new];
    effect.active = NO;
    effect.delay = 1.0;
    player.effect = effect;
    
    // now wait for a bit
    double delayInSeconds = player.effect.delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        player.effect.active = YES;
    });
    
    return [SpellInteraction cancel];
}

// goes right on top of me!
-(void)setPositionFromPlayer:(Player*)player {
    self.direction = 1;
    self.referencePosition = player.position;
    self.position = player.position;
}

@end
