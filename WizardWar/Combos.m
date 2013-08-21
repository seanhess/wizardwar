//
//  Combos.m
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Combos.h"
#import "SpellEarthwall.h"
#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellVine.h"
#import "SpellWindblast.h"
#import "SpellIcewall.h"
#import "SpellInvisibility.h"
#import "SpellFirewall.h"
#import "SpellFist.h"
#import "SpellHelmet.h"
#import "SpellHeal.h"
#import "SpellLevitate.h"
#import "SpellSleep.h"
#import "SpellLightningOrb.h"

#import "SpellFailUndies.h"
#import "SpellFailTeddy.h"
#import "SpellFailRainbow.h"
#import "SpellFailChicken.h"
#import "SpellFailHotdog.h"

#import "SpellCheeseCaptainPlanet.h"

#import "NSArray+Functional.h"
#import "SpellEffectService.h"

@interface Combos ()
@property (strong, nonatomic) NSDictionary * hitCombos;
@property (nonatomic, strong) Spell * lastSuccessfulSpell;

@end

@implementation Combos

-(id)init {
    self = [super init];
    if (self) {
        self.hitCombos = [Combos createHitCombos];
        self.allElements = [NSMutableArray array];
    }
    return self;
}

-(void)moveToElement:(ElementType)element {
    self.didMisfire = NO;
    self.castSpell = nil;
    self.disabledSpell = nil;
    self.lastElement = element;
    [self.allElements addObject:@(element)];
    self.hintedSpell = [self spellForElements:self.allElements];
}

-(void)releaseElements {
    
    // Can't cast the same spell twice!
//    if (self.sameSpellTwice) {
//        self.hintedSpell = nil;
//    }
    
    if (self.castDisabled == YES) {
        self.disabledSpell = self.hintedSpell;
        [self reset];
        return;
    }
    
    Spell * spellToCast = self.hintedSpell;
    
    if (!spellToCast) {
        self.didMisfire = YES;
//        spellToCast = [self randomFailSpell];
    }
    
    if (spellToCast) {
        self.castSpell = spellToCast;
        self.lastSuccessfulSpell = self.castSpell;
    }
    
    [self reset];
}

-(void)reset {
    self.hintedSpell = nil;
    self.allElements = [NSMutableArray array];

}

-(BOOL)hasElements {
    return (self.allElements.count > 0);
}

-(BOOL)sameSpellTwice {
    return NO;
//    return (self.hintedSpell && self.lastSuccessfulSpell.class == self.hintedSpell.class);
}

+(NSDictionary*)createHitCombos {
    NSMutableDictionary * hitCombos = [NSMutableDictionary dictionary];
        // 1 and 2 combos
//    hitCombos[@"_____"] = nil;
//    hitCombos[@"A____"] = nil;
//    hitCombos[@"_E___"] = nil;
//    hitCombos[@"__F__"] = nil;
//    hitCombos[@"___H_"] = nil;
//    hitCombos[@"____W"] = nil;
//    hitCombos[@"AE___"] = nil;
//    hitCombos[@"A_F__"] = nil;
//    hitCombos[@"A__H_"] = nil;
//    hitCombos[@"A___W"] = nil;
//    hitCombos[@"_EF__"] = nil;
//    hitCombos[@"_E_H_"] = nil;
//    hitCombos[@"_E__W"] = nil;
//    hitCombos[@"__FH_"] = nil;
//    hitCombos[@"__F_W"] = nil;
//    hitCombos[@"___HW"] = nil;
    
    // Walls: spells initially go through it
    // Ice Walls: hurting monsters and stuff.
    // Fist break helmet? Could pick where horizontally it comes down. 
    
    // 3 combos
    
    hitCombos[@"AEF__"] = Firewall;
    hitCombos[@"AE_H_"] = Heal;
    hitCombos[@"AE__W"] = Lightning;
    hitCombos[@"A_FH_"] = Fireball;
    hitCombos[@"A_F_W"] = Windblast;
    hitCombos[@"A__HW"] = Levitate;
    hitCombos[@"_EFH_"] = Helmet;
    hitCombos[@"_EF_W"] = Earthwall;
    hitCombos[@"_E_HW"] = Icewall;
    hitCombos[@"__FHW"] = Bubble;
    
    // 4 combos
    hitCombos[@"AEFH_"] = Sleep;
    hitCombos[@"AEF_W"] = Vine;
    hitCombos[@"AE_HW"] = Fist;
    hitCombos[@"A_FHW"] = Invisibility;
    hitCombos[@"_EFHW"] = Monster;
    
    // 5 combos
    // 5-combos are all unique.
    // hitCombos[@"AEFHW"] = [NSObject class];
    
    return hitCombos;
}

// EFAWH

//+(NSDictionary*)hitElements:(NSArray*)elements {
//    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
//    for (NSString * element in elements) {
//        [dict setObject:[NSNumber numberWithBool:YES] forKey:element];
//    }
//    return dict;
//}
//
//+(BOOL)hits:(NSDictionary*)hits containsElements:(NSArray*)elements {
//    for (NSString * element in elements) {
//        if (![hits objectForKey:element]) return NO;
//    }
//    
//    return YES;
//}

//+(BOOL)hits:(NSDictionary*)hits isEqualToElements:(NSArray*)elements {
//    return (elements.count == hits.count && [self hits:hits containsElements:elements]);
//}


// Produces a string key that represents whether or not each one is held down
+(NSString*)hitKey:(NSArray*)elements {
    NSMutableString * key = [NSMutableString stringWithString:@"_____"];
    [elements forEach:^(NSNumber * elementNumber) {
        ElementType element = elementNumber.intValue;
        NSString * elementId = [Elements elementId:element];
        [key replaceCharactersInRange:NSMakeRange(element, 1) withString:elementId];
    }];
    return key;
}

+(NSString*)sequenceKey:(NSArray*)elements {
    return [[self elementIds:elements] componentsJoinedByString:@""];
}

+(NSArray*)elementIds:(NSArray*)elements {
    return [elements map:^(NSNumber * elementNumber) {
        ElementType element = elementNumber.intValue;
        return [Elements elementId:element];
    }];
}

-(Spell*)randomFailSpell {
    NSArray* spells = @[SpellFailChicken.class, SpellFailRainbow.class, SpellFailHotdog.class, SpellFailTeddy.class, SpellFailUndies.class];
    
    Class SpellFailType = [spells randomItem];
    Spell * fail = [SpellFailType new];
    return fail;
}

-(Spell *)basic5Spell:(NSArray*)elements {
    // give back a fail spell based on the first element used. (CONFUSING :)
    // EARTH    chicken
    // AIR      rainbow
    // FIRE     undies
    // HEART    teddy
    // WATER    hotdog
    
    if (elements.count == 0) return nil;
    ElementType firstElement = [elements[0] intValue];
    if (firstElement == Earth)
        return [SpellFailChicken new]; // does 3 damage, but dies if it hits ANYTHING :)
    else if (firstElement == Air)
        return [SpellFailRainbow new]; // Just annoying "What does this mean?"
    else if (firstElement == Fire)
        return [SpellFailUndies new]; // _____________________
    else if (firstElement == Heart)
        return [SpellFailTeddy new]; // Heals your enemy
    else if (firstElement == Water)
        return [SpellFailHotdog new]; // Makes monsters stronger.
    
    return nil;
}

-(Spell*)exactCombo:(NSArray*)elements {
    NSString * sequence = [Combos sequenceKey:elements];
    if ([sequence isEqualToString:@"EFAWH"]) {
        return [SpellCheeseCaptainPlanet new];
    }
    return nil;
}


// COMBOS AEFHW

-(Spell*)spellForElements:(NSArray*)elements {
    
    // Hit combos catch first (they are most common)
    NSString * key = [Combos hitKey:elements];
    NSString * type = self.hitCombos[key];
    Spell * spell = nil;
    if (type) {
        Class SpellClass = [SpellEffectService.shared classForType:type];
        spell = [SpellClass new];
    }
    
    // Only worry about more specific ones with 5+
    else if (elements.count >= 5) {
        // check exact combos first
        spell = [self exactCombo:elements];
        if (!spell) spell = [self basic5Spell:elements];
    }

    return spell;
}

@end
