//
//  Combos.m
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Combos.h"
#import "NSArray+Functional.h"
#import "SpellEffectService.h"
#import "ComboService.h"

@interface Combos ()
@property (strong, nonatomic) NSDictionary * hitCombos;
@property (nonatomic, strong) Spell * lastSuccessfulSpell;

@end

@implementation Combos

-(id)init {
    self = [super init];
    if (self) {
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

-(Spell*)spellForElements:(NSArray*)elements {
    return [ComboService.shared spellForElements:elements];
}

@end
