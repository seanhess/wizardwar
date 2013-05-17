//
//  Spell.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

// COORDINATE SYSTEM
// goes from 0-100 in "units"
// speed is in units per second
// position 0 is the location of the left player

#import <Foundation/Foundation.h>
#import "RenderDelegate.h"

#define NUM_SPELL_TYPES 3
#define MAX_UNITS 100
#define MIN_UNITS 0

typedef enum ShapeType {
    SpellTypeFireball,
    SpellTypeIcewall,
    SpellTypeEarthwall,
} SpellType;

@interface Spell : NSObject
@property (nonatomic) NSString* firebaseName;
@property (nonatomic) float speed; // units per second
@property (nonatomic) float size;  // in units
@property (nonatomic) float position;  // in units
@property (nonatomic) NSTimeInterval created;
@property (nonatomic) SpellType type;
@property (nonatomic, weak) id<RenderDelegate>delegate;
-(void)update:(NSTimeInterval)dt;
-(NSDictionary*)toObject;
@end
