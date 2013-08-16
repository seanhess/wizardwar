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

-(NSComparisonResult)compare:(Effect*)effect {
    if (effect) return NSOrderedSame;
    return NSOrderedAscending;
}

-(void)start:(NSInteger)tick player:(Wizard *)player {
    self.startTick = tick;
}

-(void)cancel:(Wizard*)player {
    
}

// Default effect applied to player, is to deal damage
-(SpellInteraction*)applySpell:(Spell*)spell onWizard:(Wizard*)wizard currentTick:(NSInteger)currentTick {
    wizard.health -= spell.damage;
    
    if (spell.damage > 0)
        [wizard setStatus:WizardStatusHit atTick:currentTick];
    
    if (wizard.effect.cancelsOnHit) {
        [wizard.effect cancel:wizard];
        wizard.effect = nil;
    }
    
    return [SpellInteraction cancel];
}

// means did not intercept, go ahead with default behavior
-(SpellInteraction*)interceptSpell:(Spell*)spell onWizard:(Wizard*)wizard {
    return nil;
}

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard*)player {
    
}

@end
