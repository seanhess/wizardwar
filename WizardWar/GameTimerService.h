//
//  GameTimerService.h
//  WizardWar
//
//  Created by Sean Hess on 5/27/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import "Player.h"

#define GAME_TIMER_FIRST_TICK 1

@protocol GameTimerDelegate
-(void)gameShouldStartAt:(NSTimeInterval)startTime;
-(void)gameDidTick:(NSInteger)currentTick;
@end

// Automatically starts the syncing process right when you create it
@interface GameTimerService : NSObject
@property (nonatomic) NSTimeInterval tickInterval;
@property (nonatomic, readonly) NSInteger nextTick;
@property (nonatomic, weak) id<GameTimerDelegate> delegate;
-(id)initWithMatchNode:(Firebase*)matchNode player:(Player*)player isHost:(BOOL)isHost;
-(void)sync;
-(void)startAt:(NSTimeInterval)startTime;
-(void)stop;
-(void)update:(NSTimeInterval)dt;
@end
