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

@interface Combos ()
@property (strong, nonatomic) NSDictionary * hitCombos;

@end

@implementation Combos

-(id)init {
    self = [super init];
    if (self) {
        self.hitCombos = [Combos createHitCombos];
    }
    return self;
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
    
    // 3 combos
    hitCombos[@"AEF__"] = [SpellFirewall class];
    hitCombos[@"AE_H_"] = [SpellHeal class];
    hitCombos[@"AE__W"] = [SpellIcewall class];
    hitCombos[@"A_FH_"] = [SpellFireball class];
    hitCombos[@"A_F_W"] = [SpellWindblast class];
    hitCombos[@"A__HW"] = [SpellBubble class];
    hitCombos[@"_EFH_"] = [SpellHelmet class];
    hitCombos[@"_EF_W"] = [NSObject class];
    hitCombos[@"_E_HW"] = [SpellEarthwall class];
    hitCombos[@"__FHW"] = [NSObject class];
    
    // 4 combos
    hitCombos[@"AEFH_"] = [NSObject class];
    hitCombos[@"AEF_W"] = [SpellVine class];
    hitCombos[@"AE_HW"] = [SpellFist class];
    hitCombos[@"A_FHW"] = [SpellInvisibility class];
    hitCombos[@"_EFHW"] = [SpellMonster class];
    
    // 5 combos
    hitCombos[@"AEFHW"] = [NSObject class];
    
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

// Hit key: sort them, then put them out
+(NSString*)hitKey:(NSArray*)elements {
    NSMutableString * key = [NSMutableString stringWithString:@"_____"];
    for (NSString * elementId in elements) {
        ElementType element = [Elements elementWithId:elementId];
        [key replaceCharactersInRange:NSMakeRange(element, 1) withString:elementId];
    }
    return key;
}


// COMBOS AEFHW

-(Spell*)spellForElements:(NSArray*)elements {
    
    NSString * key = [Combos hitKey:elements];
    Class SpellClass = self.hitCombos[key];
    if (SpellClass != [NSObject class])
        return [SpellClass new];

    return nil;
}

@end
