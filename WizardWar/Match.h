//
//  Match.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"
#import "Player.h"
#import "Multiplayer.h"
#import "TimerSyncService.h"

#define TICK_INTERVAL 0.1
#define TICKS_PER_SECOND 1/TICK_INTERVAL

typedef enum MatchStatus {
    MatchStatusReady,
    MatchStatusPlaying,
    MatchStatusEnded,
} MatchStatus;

#define MATCH_STATE_KEYPATH @"status"

@protocol MatchDelegate
-(void)didAddSpell:(Spell*)spell;
-(void)didRemoveSpell:(Spell*)spell;

-(void)didAddPlayer:(Player*)player;
-(void)didRemovePlayer:(Player*)player;

-(void)didTick:(NSInteger)currentTick;
@end

@interface Match : NSObject
@property (nonatomic, strong) NSMutableDictionary * players;
@property (nonatomic, strong) NSMutableDictionary * spells;
@property (nonatomic, weak) id<MatchDelegate> delegate;
@property (nonatomic, strong) Player * currentPlayer;

@property (nonatomic, readonly) NSArray * sortedPlayers;

@property (nonatomic) MatchStatus status;

-(id)initWithId:(NSString*)matchId currentPlayer:(Player*)player withAI:(Player*)ai multiplayer:(id<Multiplayer>)multiplayer sync:(TimerSyncService*)sync;
-(void)update:(NSTimeInterval)dt;
-(void)castSpell:(Spell *)spell;
-(void)connect;
-(void)disconnect;
@end
