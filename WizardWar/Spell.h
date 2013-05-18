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
#import "Player.h"
#import "SpellInteraction.h"

@interface Spell : NSObject
@property (nonatomic) NSString* firebaseName;
@property (nonatomic) float speed; // units per second
@property (nonatomic) float size;  // in units
@property (nonatomic) float position;  // in units
@property (nonatomic) NSInteger direction;  // 1, or -1
@property (nonatomic) NSInteger damage;
@property (nonatomic) NSTimeInterval created;
@property (nonatomic) NSString * type; // tells me which class to instantiate. Use the string representation
@property (nonatomic) NSString * creator;
@property (nonatomic, weak) id<RenderDelegate>delegate;
@property (nonatomic, strong) Spell * lastHitSpell;
-(void)update:(NSTimeInterval)dt;
-(NSDictionary*)toObject;
-(void)setPositionFromPlayer:(Player*)player;
-(BOOL)isType:(Class)class;
-(SpellInteraction*)interactSpell:(Spell*)spell;
-(SpellInteraction*)interactPlayer:(Player*)spell; // ???
-(BOOL)hitsPlayer:(Player*)player;
-(BOOL)hitsSpell:(Spell*)spell;
+(Spell*)fromType:(NSString*)type;
-(void)reflectFromSpell:(Spell*)spell;
@end
