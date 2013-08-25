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
#import "PlayerEffect.h"
#import "Simulated.h"
#import "SpellInfo.h"

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
@property (nonatomic) float speedY; // altitude per second
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
@property (nonatomic) float altitude; // how high it is. normal = 0;
@property (nonatomic) BOOL heavy; // if it falls
@property (nonatomic) BOOL targetSelf;
@property (nonatomic) BOOL isWall;
@property (nonatomic, strong) NSString * name;
@property (nonatomic) CGFloat castDelay; // delay after cast
@property (nonatomic, strong) Spell * linkedSpell;
@property (nonatomic, strong) SpellEffect * spellEffect; // the spell is affected
@property (nonatomic) CGFloat height;

// how far away from the wizard should it start
@property (nonatomic) float startOffsetPosition;

-(id)initWithInfo:(SpellInfo*)info;

-(void)initCaster:(Wizard*)player tick:(NSInteger)tick;

-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval;

-(BOOL)hitsPlayer:(Wizard*)player duringInterval:(NSTimeInterval)dt;
-(BOOL)didHitSpell:(Spell*)spell duringInterval:(NSTimeInterval)dt;
+(Spell*)fromType:(NSString*)type;
-(float)moveDx:(NSTimeInterval)dt;
-(float)move:(NSTimeInterval)dt;
-(float)moveFromReferencePosition:(NSTimeInterval)dt;
+(NSString*)generateSpellId;
-(void)setPositionFromPlayer:(Wizard*)player;

-(BOOL)isType:(NSString*)type;
-(BOOL)isAnyType:(NSArray*)type; // if the spell is any of types
+(BOOL)type:(NSString*)type isType:(NSString*)type; // if the spell is any of types
+(BOOL)type:(NSString*)type isAnyType:(NSArray*)type; // if the spell is any of types
@end
