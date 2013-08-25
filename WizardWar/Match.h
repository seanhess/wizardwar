//
//  Match.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"
#import "Wizard.h"
#import "Multiplayer.h"
#import "TimerSyncService.h"
#import "Simulated.h"
#import "AIService.h"

typedef enum MatchStatus {
    MatchStatusReady,
    MatchStatusSyncing,
    MatchStatusPlaying,
    MatchStatusEnded,
} MatchStatus;

#define MATCH_STATE_KEYPATH @"status"

@protocol MatchDelegate
-(void)didAddSpell:(Spell*)spell;
-(void)didRemoveSpell:(Spell*)spell;

-(void)didAddPlayer:(Wizard*)player;
-(void)didRemovePlayer:(Wizard*)player;

-(void)didTick:(NSInteger)currentTick;
@end

@interface Match : NSObject <Simulated>
@property (nonatomic, strong) NSString * matchId;
@property (nonatomic, weak) id<MatchDelegate> delegate;
@property (nonatomic, strong) Wizard * currentWizard;

@property (nonatomic, strong) NSMutableArray * sortedPlayers;
@property (nonatomic) MatchStatus status;
@property (nonatomic, strong) id<AIService>ai;

@property (nonatomic, strong) NSMutableArray * mainPlayerSpellHistory;

-(id)initWithMatchId:(NSString*)matchId hostName:(NSString*)hostName currentWizard:(Wizard*)wizard withAI:(id<AIService>)ai multiplayer:(id<Multiplayer>)multiplayer sync:(TimerSyncService*)sync;
-(void)update:(NSTimeInterval)dt;
-(BOOL)castSpell:(Spell *)spell;
-(void)connect;
-(void)disconnect;
@end
