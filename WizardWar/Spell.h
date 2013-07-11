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
#import "Wizard.h"
#import "SpellInteraction.h"
#import "Effect.h"
#import "Simulated.h"

typedef enum SpellStatus {
    SpellStatusPrepare,
    SpellStatusActive,
    SpellStatusDestroyed,
    SpellStatusUpdated,
} SpellStatus;


@interface Spell : NSObject <Objectable, Simulated>
@property (nonatomic, strong) NSString * spellId;
@property (nonatomic) float speed; // units per second
@property (nonatomic) float position;  // in units
@property (nonatomic) float referencePosition; // where it started, or last sync
@property (nonatomic) NSInteger direction;  // 1, or -1
@property (nonatomic) NSInteger strength;
@property (nonatomic) NSInteger damage;
@property (nonatomic) NSTimeInterval created;
@property (nonatomic, strong) NSString * type; // tells me which class to instantiate. Use the string representation
@property (nonatomic) NSInteger createdTick;
@property (nonatomic) NSInteger updatedTick;
@property (nonatomic) SpellStatus status;
@property (nonatomic, strong) NSString * creator;
@property (nonatomic) NSInteger altitude; // how high it is. normal = 0;
@property (nonatomic) BOOL heavy; // if it falls
@property (nonatomic, strong) Effect * effect; // if the spell creates an effect
@property (nonatomic) BOOL targetSelf;

// how far away from the wizard should it start
@property (nonatomic) float startOffsetPosition;

-(void)update:(NSTimeInterval)dt;
-(void)initCaster:(Wizard*)player tick:(NSInteger)tick;
-(BOOL)isType:(Class)class;

-(SpellInteraction*)interactSpell:(Spell*)spell;
-(SpellInteraction*)interactWizard:(Wizard*)wizard currentTick:(NSInteger)currentTick;

-(BOOL)hitsPlayer:(Wizard*)player duringInterval:(NSTimeInterval)dt;
-(BOOL)hitsSpell:(Spell*)spell duringInterval:(NSTimeInterval)dt;
+(Spell*)fromType:(NSString*)type;
+(NSString*)type;
-(float)move:(NSTimeInterval)dt;
-(float)moveFromReferencePosition:(NSTimeInterval)dt;
+(NSString*)generateSpellId;
@end
