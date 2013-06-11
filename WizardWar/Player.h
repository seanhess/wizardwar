//
//  Player.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Units.h"
#import "Objectable.h"
#import "Effect.h"

#define WIZARD_TYPE_ONE @"1"
#define WIZARD_TYPE_TWO @"2"

typedef enum PlayerState {
    PlayerStateReady,
    PlayerStateCast,
    PlayerStateHit,
    PlayerStateDead,
} PlayerState;

@interface Player : NSObject <Objectable>
@property (nonatomic, strong) NSString * name;
@property (nonatomic) PlayerState state;
@property (nonatomic) float position; // in units (not pixels)
@property (nonatomic) NSInteger health;
@property (nonatomic, strong) NSString * wizardType;
@property (nonatomic, strong) Effect * effect; // current effect applied

-(BOOL)isFirstPlayer;
-(void)setState:(PlayerState)state animated:(BOOL)animated;
-(void)update:(NSTimeInterval)dt;
+(NSString*)randomWizardType;
@end
