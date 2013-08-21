//
//  SpellEffectService.h
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpellEffect.h"
#import "PlayerEffect.h"

@interface SpellInteraction2 : NSObject
@property (nonatomic, strong) Class spell;
@property (nonatomic, strong) Class otherSpell;
@property (nonatomic, strong) SpellEffect* effect;
@end


@interface SpellEffectService : NSObject
-(NSArray*)interactionsForSpell:(Class)SpellOne andSpell:(Class)SpellTwo;
-(PlayerEffect*)playerEffectForSpell:(Class)Spell;
@end
