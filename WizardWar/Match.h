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

@protocol MatchDelegate
-(void)didRemoveSpell:(Spell*)spell;
-(void)didAddSpell:(Spell*)spell;
-(void)matchStarted;
-(void)matchEnded;
@end

@interface Match : NSObject
@property (nonatomic, strong) NSMutableArray * players;
@property (nonatomic, strong) NSMutableArray * spells;
@property (nonatomic, weak) id<MatchDelegate> delegate;
@property (nonatomic, strong) Player * currentPlayer;
@property (nonatomic) BOOL started;
@property (nonatomic, strong) Player * loser;
-(void)update:(NSTimeInterval)dt;
-(void)addSpell:(Spell*)spell;
-(id)initWithId:(NSString*)id currentPlayer:(Player*)player;
@end
