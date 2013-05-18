//
//  Player.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Units.h"
#import "RenderDelegate.h"

typedef enum PlayerState {
    PlayerStateReady,
    PlayerStateCast,
    PlayerStateHit,
    PlayerStateDead,
} PlayerState;

@interface Player : NSObject
@property (nonatomic, strong) NSString * name;
@property (nonatomic) PlayerState state;
@property (nonatomic) float position; // in units (not pixels)
@property (nonatomic) float mana;
@property (nonatomic) NSInteger health;
@property (nonatomic, weak) id<RenderDelegate>delegate;
-(NSDictionary*)toObject;
-(BOOL)isFirstPlayer;
-(void)setState:(PlayerState)state animated:(BOOL)animated;
-(void)update:(NSTimeInterval)dt;
@end
