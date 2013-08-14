//
//  SpellLayer.h
//  WizardWar
//
//  Created by Sean Hess on 8/14/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

// Loads the spell spritesheets and puts them in the correct layer, etc

#import "CCLayer.h"
#import "SpellSprite.h"

@interface SpellsLayer : CCLayer
@property (nonatomic, readonly) id<NSFastEnumeration> allSpellSprites;
-(void)addSpell:(SpellSprite*)spell;
@end
