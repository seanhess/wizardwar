//
//  SpellEffect.m
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellEffect.h"
#import "SpellBubble.h"
#import "EffectSleep.h"

// TODO newer wall
// TODO fireball, bubble: don't react over and over with bubble when carried
// TODO fireball: don't react with earthwall if carried by bubble
// TODO fireball, bubble: don't blow up on icewall if carried by bubble
// TODO monster: only interact with other monsters if going different directions
// TODO monster: no speed if asleep

@implementation SpellEffect
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    NSLog(@"OVERRIDE effectSpell");
    abort();
    return NO;
}
@end

@implementation SENone
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    return NO;
}
@end

@implementation SEWeaker
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    spell.strength -= otherSpell.damage;
    if (spell.strength < 0)
        spell.strength = 0;
    return YES;
}
@end

@implementation SEDestroy
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    spell.strength = 0;
    return YES;
}
@end

@implementation SEStronger
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    spell.damage += 1;
    spell.strength += 1;
    return YES;
}
@end

@implementation SECarry
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    // TODO: make sure they don't hit multiple times, if already carried
//    spell.linkedSpell = otherSpell;
    spell.position = otherSpell.position;
    spell.speed = otherSpell.speed;
    spell.direction = otherSpell.direction;
    return YES;
}
@end

@implementation SESleep
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    spell.speed = 0;
    spell.effect = [EffectSleep new];
    [spell.effect start:tick player:nil];
    return YES;
}
@end

@implementation SESpeed
+(id)setTo:(CGFloat)speed {
    SESpeed * effect = [SESpeed new];
    effect.set = speed;
    return effect;
}

+(id)speedUp:(CGFloat)up slowDown:(CGFloat)down {
    SESpeed * effect = [SESpeed new];
    effect.up = up;
    effect.down = down;
    return effect;
}

-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell {
    if (self.up > 0) {
        if (spell.direction == otherSpell.direction) {
            spell.speed += self.up;
        }
        else {
            spell.speed -= self.down;
            if (spell.speed < 0) {
                spell.direction *= -1;
                spell.speed *= -1;
            }            
        }
    } else {
        spell.speed = self.set;
    }
    return YES;
}

@end

@implementation SEReflect
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell {
    spell.direction = otherSpell.direction;
    return YES;
}
@end

