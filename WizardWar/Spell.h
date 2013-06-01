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
#import "Player.h"
#import "SpellInteraction.h"


typedef enum SpellStatus {
    SpellStatusPrepare,
    SpellStatusActive,
    SpellStatusDestroyed,
} SpellStatus;


@interface Spell : NSObject <Objectable>
@property (nonatomic) NSString * spellId;
@property (nonatomic) float speed; // units per second
@property (nonatomic) float position;  // in units
@property (nonatomic) float referencePosition; // where it started, or last sync
@property (nonatomic) NSInteger direction;  // 1, or -1
@property (nonatomic) NSInteger strength;
@property (nonatomic) NSInteger damage;
@property (nonatomic) NSTimeInterval created;
@property (nonatomic) NSString * type; // tells me which class to instantiate. Use the string representation
@property (nonatomic) NSInteger createdTick;
@property (nonatomic) NSInteger updatedTick;
@property (nonatomic) SpellStatus status;
@property (nonatomic) NSInteger castTimeInTicks;



// how far away from the wizard should it start
@property (nonatomic) float startOffsetPosition;

-(void)update:(NSTimeInterval)dt;
-(void)setPositionFromPlayer:(Player*)player;
-(BOOL)isType:(Class)class;
-(SpellInteraction*)interactSpell:(Spell*)spell;
-(SpellInteraction*)interactPlayer:(Player*)spell; // ???
-(BOOL)hitsPlayer:(Player*)player duringInterval:(NSTimeInterval)dt;
-(BOOL)hitsSpell:(Spell*)spell duringInterval:(NSTimeInterval)dt;
+(Spell*)fromType:(NSString*)type;
-(void)reflectFromSpell:(Spell*)spell;
-(float)move:(NSTimeInterval)dt;
-(float)moveFromReferencePosition:(NSTimeInterval)dt;
+(NSString*)generateSpellId;
@end
