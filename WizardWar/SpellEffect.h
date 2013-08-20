

//
//  SpellEffect.h
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"

@interface SpellEffect : NSObject
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick;
@end



@interface SENone : SpellEffect
@end

@interface SEWeaker : SpellEffect
@end

@interface SEDestroy : SpellEffect
@end

@interface SEStronger : SpellEffect
@end

@interface SECarry : SpellEffect
@end

@interface SESleep : SpellEffect
@end

@interface SESpeed : SpellEffect
@property (nonatomic) CGFloat set;
@property (nonatomic) CGFloat up;
@property (nonatomic) CGFloat down;

+(id)setTo:(CGFloat)speed;
+(id)speedUp:(CGFloat)speed slowDown:(CGFloat)speed;
@end

@interface SEReflect : SpellEffect
@end
