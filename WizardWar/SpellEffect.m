//
//  SpellEffect.m
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellEffect.h"
#import "PESleep.h"
#import "Spell.h"
#import "SpellInfo.h"

@implementation SpellEffect
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    NSLog(@"OVERRIDE effectSpell");
    abort();
    return NO;
}
-(NSString*)describe:(NSString *)type {
    return @"";
}
@end

@implementation SENone
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    return NO;
}
@end

@implementation SEWeaker
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    if (spell.direction == otherSpell.direction) return NO;
    // only check if the spell that will make ME weaker is carried
    if ([SECarry isCarried:otherSpell]) return NO;
    spell.strength -= otherSpell.damage;
    if (spell.strength < 0)
        spell.strength = 0;
    return YES;
}
-(NSString*)describe:(NSString *)type {
    return [NSString stringWithFormat:@"%@ grows weaker", type];
}
@end

@implementation SEDestroy
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    if (spell.direction == otherSpell.direction) return NO;
    if ([SECarry isCarried:spell]) return NO;
    if ([SECarry isCarried:otherSpell]) return NO;
    spell.strength = 0;
    return YES;
}
-(NSString*)describe:(NSString *)type {
    return [NSString stringWithFormat:@"%@ is destroyed", type];
}@end

@implementation SEDestroyOlder
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    // do not destroy if I am newer than them
    if (spell.createdTick > otherSpell.createdTick) return NO;
    if ([SECarry isCarried:spell]) return NO;
    spell.strength = 0;
    return YES;
}
-(NSString*)describe:(NSString *)type {
    return @"The newer wall replaces the older";
}
@end


@implementation SEStronger
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    // it DOES interact with stronger, because I want it to :)
    spell.damage += 1;
    spell.strength += 1;
    return YES;
}
-(NSString*)describe:(NSString *)type {
    return [NSString stringWithFormat:@"%@ grows stronger", type];
}
@end

@implementation SECarry
+(BOOL)isCarried:(Spell*)spell {
    if ([spell.linkedSpell isType:Bubble] && spell.linkedSpell.status != SpellStatusDestroyed) return YES;
    return NO;
}

-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
//    if ([SECarry isCarried:spell]) return NO;
    
    if ([spell.linkedSpell isType:Bubble] && spell.linkedSpell.createdTick >= otherSpell.createdTick) return NO;
    
    // TODO: make sure they don't hit multiple times, if already carried
    if (spell.position == otherSpell.position && spell.speed == otherSpell.speed && spell.direction == otherSpell.direction)
        return NO;
    
    spell.linkedSpell = otherSpell;
    spell.position = otherSpell.position;
    spell.speed = otherSpell.speed;
    spell.direction = otherSpell.direction;
    return YES;
}
-(NSString*)describe:(NSString *)type {
    return [NSString stringWithFormat:@"%@ is carried", type];
}
@end

@implementation SESleep
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    if ([SECarry isCarried:spell]) return NO;
    
    spell.speed = 0;
    spell.spellEffect = self;
//    spell.linkedSpell = otherSpell;
//    spell.effect = [EffectSleep new];
//    [spell.effect start:tick player:nil];
    return YES;
}
-(NSString*)describe:(NSString *)type {
    return [NSString stringWithFormat:@"%@ falls asleep", type];
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

-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    // they don't work in the same direction? I don't think so!
    if ([SECarry isCarried:spell]) return NO;
    if ([spell.spellEffect isKindOfClass:[SESleep class]]) return NO;
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
        // sets only work in one direction? Bah, I guess so :)
        if (spell.direction == otherSpell.direction) return NO;
        spell.speed = self.set;
    }
    return YES;
}

-(NSString*)describe:(NSString *)type {
    if (self.set)
        return [NSString stringWithFormat:@"%@ slows down to %i", type, (int)self.set];

    return [NSString stringWithFormat:@"%@ changes speed by %i/-%i", type, (int)self.up, (int)self.down];
}

@end

@implementation SEReflect
-(BOOL)applyToSpell:(Spell*)spell otherSpell:(Spell*)otherSpell tick:(NSInteger)tick {
    if (spell.direction == otherSpell.direction) return NO;
    if ([SECarry isCarried:spell]) return NO;
    spell.direction = otherSpell.direction;
    return YES;
}
-(NSString*)describe:(NSString *)type {
    return [NSString stringWithFormat:@"%@ is reflected", type];
}
@end

