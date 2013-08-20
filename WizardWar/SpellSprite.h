//
//  SpellSprite.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "CCSprite.h"
#import "Spell.h"
#import "Units.h"

@interface SpellSprite : CCSprite
-(id)initWithSpell:(Spell*)spell units:(Units*)units;
@property (nonatomic, strong) Spell * spell;
@property (nonatomic, strong) NSString * explodeAnimationName;

+(BOOL)isSingleImage:(Spell*)spell;
+(BOOL)isNoRender:(Spell*)spell;
+(NSString*)sheetName:(Spell*)spell;
+(NSString*)sheetNameForClass:(Class)spellClass;
+(NSString*)castAnimationName:(Spell*)spell;
+(CCSpriteFrame*)singleImageFrame:(Spell*)spell;
@end
