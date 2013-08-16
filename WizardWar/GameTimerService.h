//
//  GameTimerService.h
//  WizardWar
//
//  Created by Sean Hess on 5/27/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wizard.h"
#import "GameTime.h"

#define GAME_TIMER_FIRST_TICK 1

@protocol GameTimerDelegate
-(void)gameDidTick:(NSInteger)currentTick;
@end

// Automatically starts the syncing process right when you create it
@interface GameTimerService : NSObject
@property (nonatomic) CGFloat gameTime;
@property (nonatomic) NSTimeInterval tickInterval;
@property (nonatomic) NSTimeInterval nextTickTime;
@property (nonatomic, readonly) NSInteger nextTick;
@property (nonatomic, weak) id<GameTimerDelegate> delegate;
-(void)start;
-(void)stop;
-(void)update:(NSTimeInterval)dt;
-(void)startFromRemoteTime:(GameTime*)gameTime;
-(void)updateFromRemoteTime:(NSTimeInterval)gameTime;
@end
