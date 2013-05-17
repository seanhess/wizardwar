//
//  SpellSprite.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "CCSprite.h"
#import "Spell.h"

@interface SpellSprite : CCSprite <RenderDelegate>
-(id)initWithSpell:(Spell*)spell;
@property (nonatomic, strong) Spell * spell;
@end
