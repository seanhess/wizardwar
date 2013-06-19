//
//  GameTimerService.h
//  WizardWar
//
//  Created by Sean Hess on 5/27/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wizard.h"

#define GAME_TIMER_FIRST_TICK 1

@protocol GameTimerDelegate
-(void)gameDidTick:(NSInteger)currentTick;
@end

// Automatically starts the syncing process right when you create it
@interface GameTimerService : NSObject
@property (nonatomic) NSTimeInterval tickInterval;
@property (nonatomic, readonly) NSInteger nextTick;
@property (nonatomic, weak) id<GameTimerDelegate> delegate;
-(void)startAt:(NSTimeInterval)startTime;
-(void)stop;
-(void)update:(NSTimeInterval)dt;
@end
