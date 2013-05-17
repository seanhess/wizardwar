//
//  Spell.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUM_SPELL_TYPES 3

typedef enum ShapeType {
    SpellTypeFireball,
    SpellTypeIcewall,
    SpellTypeEarthwall,
} SpellType;

@interface Spell : NSObject
@property (nonatomic) NSInteger speed;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger position;
@property (nonatomic) NSTimeInterval created;
@property (nonatomic) SpellType type;
-(void)update:(NSTimeInterval)dt;
@end
