//
//  Combos.m
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Combos.h"
#import "SpellFireball.h"
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

#import "SpellFailUndies.h"
#import "SpellFailTeddy.h"
#import "SpellFailRainbow.h"
#import "SpellFailChicken.h"
#import "SpellFailHotdog.h"

#import "NSArray+Functional.h"
#import "SpellFail.h"

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
    
    hitCombos[@"AEF__"] = [SpellFirewall class];
    hitCombos[@"AE_H_"] = [SpellHeal class];
    hitCombos[@"AE__W"] = [SpellSleep class]; // Tornado, Geyser, Sleep,
    hitCombos[@"A_FH_"] = [SpellFireball class];
    hitCombos[@"A_F_W"] = [SpellWindblast class];
    hitCombos[@"A__HW"] = [SpellLevitate class];
    hitCombos[@"_EFH_"] = [SpellHelmet class];
    hitCombos[@"_EF_W"] = [SpellEarthwall class];
    hitCombos[@"_E_HW"] = [SpellIcewall class]; // hurts monsters. goes down. 
    hitCombos[@"__FHW"] = [SpellBubble class];
    
    // 4 combos
//  hitCombos[@"AEFH_"] = [NSObject class];
    hitCombos[@"AEF_W"] = [SpellVine class];
    hitCombos[@"AE_HW"] = [SpellFist class];
    hitCombos[@"A_FHW"] = [SpellInvisibility class];
    hitCombos[@"_EFHW"] = [SpellMonster class];
    
    // 5 combos
    // 5-combos are all unique.
    // hitCombos[@"AEFHW"] = [NSObject class];
    
    return hitCombos;
}

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


// COMBOS AEFHW

-(Spell*)spellForElements:(NSArray*)elements {
    NSString * key = [Combos hitKey:elements];
    Class SpellClass = self.hitCombos[key];
    Spell * spell = nil;
    if (SpellClass) {
        spell = [SpellClass new];
    }
    
    else if (elements.count >= 5) {
        spell = [self basic5Spell:elements];
    }

    return spell;
}

@end
