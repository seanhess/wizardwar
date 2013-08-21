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
#import "SpellInfo.h"

@interface SpellEffectService : NSObject

+ (SpellEffectService *)shared;

@property (nonatomic, strong) NSArray * allSpellTypes;


-(NSArray*)interactionsForSpell:(NSString*)SpellOne andSpell:(NSString*)SpellTwo;
-(PlayerEffect*)playerEffectForSpell:(NSString*)Spell;

-(SpellInfo*)infoForType:(NSString*)type;

@end
