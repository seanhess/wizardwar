//
//  SingleplayerService.m
//  WizardWar
//
//  Created by Sean Hess on 5/29/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SingleplayerService.h"

@implementation SingleplayerService
@synthesize delegate;

// basically don't do anything
-(void)connectToMatchId:(NSString*)matchId {}

-(void)disconnect {}

-(void)addPlayer:(Player*)player {}
-(void)updatePlayer:(Player*)player {}
-(void)removePlayer:(Player*)player {}

-(void)addSpell:(Spell*)spell onTick:(NSInteger)tick {}
-(void)updateSpell:(Spell*)spell onTick:(NSInteger)tick {}
-(void)removeSpells:(NSArray*)spell {}

@end
