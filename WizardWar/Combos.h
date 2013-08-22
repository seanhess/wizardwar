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







// Note this tracks the current state of the combos. You need to be able to create new copies of this.


@interface Combos : NSObject

@property (nonatomic) ElementType lastElement;
@property (nonatomic, strong) NSMutableArray * allElements;

@property (nonatomic) BOOL castDisabled;
@property (nonatomic, strong) Spell * hintedSpell;
@property (nonatomic, strong) Spell * castSpell;
@property (nonatomic, strong) Spell * disabledSpell;
@property (nonatomic) BOOL didMisfire;

@property (nonatomic, readonly) BOOL sameSpellTwice;
@property (nonatomic, readonly) BOOL hasElements;

-(void)moveToElement:(ElementType)element;
-(void)releaseElements;
-(void)reset;


@end
