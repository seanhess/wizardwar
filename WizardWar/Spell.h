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
#import "PlayerEffect.h"
#import "Simulated.h"

@class SpellEffect;

typedef enum SpellStatus {
    SpellStatusPrepare,
    SpellStatusActive,
    SpellStatusDestroyed,
    SpellStatusUpdated,
} SpellStatus;


@interface Spell : NSObject <Objectable>
@property (nonatomic, strong) NSString * spellId;
@property (nonatomic) float speed; // units per second
@property (nonatomic) float position;  // in units
@property (nonatomic) float referencePosition; // where it started, or last sync
@property (nonatomic) NSInteger direction;  // 1, or -1
@property (nonatomic) NSInteger strength;
@property (nonatomic) NSInteger damage;
@property (nonatomic, strong) NSString * type; // tells me which class to instantiate. Use the string representation
@property (nonatomic) NSInteger createdTick;
@property (nonatomic) NSInteger updatedTick;
@property (nonatomic) SpellStatus status;
@property (nonatomic, strong) Wizard * creator;
@property (nonatomic) NSInteger altitude; // how high it is. normal = 0;
@property (nonatomic) BOOL heavy; // if it falls
@property (nonatomic, strong) PlayerEffect * effect; // if the spell creates an effect
@property (nonatomic, strong) SpellEffect * spellEffect;
@property (nonatomic) BOOL targetSelf;
@property (nonatomic, strong) NSString * name;
@property (nonatomic) CGFloat castDelay; // delay after cast
@property (nonatomic, strong) Spell * linkedSpell;

// how far away from the wizard should it start
@property (nonatomic) float startOffsetPosition;

-(void)initCaster:(Wizard*)player tick:(NSInteger)tick;
-(BOOL)isType:(Class)class;

-(SpellInteraction*)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval;
-(SpellInteraction*)interactSpell:(Spell*)spell currentTick:(NSInteger)currentTick;
-(SpellInteraction*)interactWizard:(Wizard*)wizard currentTick:(NSInteger)currentTick;

-(BOOL)hitsPlayer:(Wizard*)player duringInterval:(NSTimeInterval)dt;
-(BOOL)didHitSpell:(Spell*)spell duringInterval:(NSTimeInterval)dt;
+(Spell*)fromType:(NSString*)type;
+(Class)classFromType:(NSString*)type;
+(NSString*)type;
-(float)moveDx:(NSTimeInterval)dt;
-(float)move:(NSTimeInterval)dt;
-(float)moveFromReferencePosition:(NSTimeInterval)dt;
+(NSString*)generateSpellId;
-(void)setPositionFromPlayer:(Wizard*)player;
@end
