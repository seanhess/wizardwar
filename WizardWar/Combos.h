//
//  Combos.h
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Elements.h"
#import "Spell.h"

@interface Combos : NSObject

// an array of all moves, in order
@property (nonatomic) ElementType lastElement;
@property (nonatomic, strong) NSMutableArray * allElements;

@property (nonatomic) BOOL castDisabled;
@property (nonatomic, strong) Spell * hintedSpell;
@property (nonatomic, strong) Spell * castSpell;
@property (nonatomic) BOOL didMisfire;

@property (nonatomic, readonly) BOOL sameSpellTwice;
@property (nonatomic, readonly) BOOL hasElements;

+(NSArray*)allSpellClasses;

-(void)moveToElement:(ElementType)element;
-(void)releaseElements;

-(Spell*)spellForElements:(NSArray*)elements;

@end
