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
#import "SpellInteraction.h"

@interface SpellEffectService : NSObject
-(NSArray*)interactionsForSpell:(NSString*)SpellOne andSpell:(NSString*)SpellTwo;
-(PlayerEffect*)playerEffectForSpell:(NSString*)Spell;
@end
