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

typedef enum MatchState {
    MatchStateReady,
    MatchStatePlaying,
    MatchStateEnded,
} MatchState;

#define MATCH_STATE_KEYPATH @"state"

@protocol MatchDelegate
-(void)didRemoveSpell:(Spell*)spell;
-(void)didAddSpell:(Spell*)spell;
-(void)didUpdateHealthAndMana;
@end

@interface Match : NSObject
@property (nonatomic, strong) NSMutableArray * players;
@property (nonatomic, strong) NSMutableArray * spells;
@property (nonatomic, weak) id<MatchDelegate> delegate;
@property (nonatomic, strong) Player * currentPlayer;
@property (nonatomic, strong) Player * opponentPlayer;

@property (nonatomic) MatchState state;

-(void)update:(NSTimeInterval)dt;
-(void)addSpell:(Spell*)spell;
-(id)initWithId:(NSString*)id currentPlayer:(Player*)player withAI:(Player*)ai;
-(void)castSpell:(Spell *)spell;

-(void)disconnect;
@end
