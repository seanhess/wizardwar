//
//  AIOpponent.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AIOpponent.h"
#import "NSArray+Functional.h"
#import "AITactic.h"
#import <ReactiveCocoa.h>
#import "RACSignal+Filters.h"

#define MESSAGE_DURATION 4.0

@interface AIOpponent ()
@property (nonatomic) NSInteger wizardHealth;
@property (nonatomic) NSInteger opponentHealth;
@end

@implementation AIOpponent
@synthesize wizard = _wizard;
@synthesize opponent = _opponent;
@synthesize delegate = _delegate;
@synthesize hideControls = _hideControls;
@synthesize environment = _environment;
@synthesize disableControls = _disableControls;
@synthesize allowedSpells = _allowedSpells;
@synthesize helpSelectedElements = _helpSelectedElements;

-(id)init {
    if ((self = [super init])) {
        self.game = [AIGameState new];
        RAC(self.wizardHealth) = [RACAbleWithStart(self.wizard.health) safe];
        RAC(self.opponentHealth) = [RACAbleWithStart(self.opponent.health) safe];        
    }
    return self;
}

-(void)setWizard:(Wizard *)wizard {
    _wizard = wizard;
    self.game.wizard = wizard;
    [self checkPreActions];    
}

-(void)setOpponent:(Wizard *)opponent {
    _opponent = opponent;
    self.game.opponent = opponent;
}

-(void)didTapControls {
    // used in tutorial
}

-(void)opponent:(Wizard*)wizard didCastSpell:(Spell*)spell atTick:(NSInteger)tick {
    // not sure if I need this any more...
}

-(void)setTactics:(NSArray *)tactics {
    _tactics = tactics;
    self.game.lastSpellCast = nil; // wipe this out so timers aren't still in play
    [self checkPreActions];
}

-(void)checkPreActions {
    if (!self.tactics) return;
    if (!self.wizard) return;
    for (id<AITactic>tactic in self.tactics) {
        if ([tactic respondsToSelector:@selector(preAction)]) {
            AIAction * action = [tactic preAction];
            if (action) {
                [self runAction:action atTick:self.game.currentTick];
            }
        }
    }
}

-(void)runEndActions:(BOOL)didWin {
    for (id<AITactic>tactic in self.tactics) {
        if ([tactic respondsToSelector:@selector(endAction:)]) {
            AIAction * action = [tactic endAction:didWin];
            if (action) {
                [self runAction:action atTick:self.game.currentTick];
            }
        }
    }
}

-(void)simulateTick:(NSInteger)tick interval:(NSTimeInterval)interval spells:(NSArray*)spells {
    self.game.currentTick = tick;
    self.game.interval = interval;
    self.game.spells = spells;
    
    // now, loop through our tactics.
    
    if (!self.tactics.count) return;
    
    // find the highest priority time required action
    BOOL priority = 0;
    AIAction * priorityAction;
    
    for (id<AITactic>tactic in self.tactics) {
        AIAction * action = [tactic suggestedAction:self.game];
        
        if (action) {
//            NSLog(@"(%i) %@", tick, action);
            
            if (action.timeRequired <= 0) {
                [self runAction:action atTick:tick];
            }
            
            else if (!priorityAction || action.priority > priority) {
                priority = action.priority;
                priorityAction = action;
            }
        }
    }
    
    if (priorityAction) {
        NSLog(@"(%i) %@", tick, priorityAction);
        [self runAction:priorityAction atTick:tick];
    }
}

-(void)runAction:(AIAction*)action atTick:(NSInteger)tick {
    
//    NSLog(@"      RUN %@", action);
    // How does it CLEAR the action?
    // maybe they fade on their own.
    
    // how does it clear the message?
    // they always fade out over time?
    // sure. 
    
    if (action.message) {
        if (action.message.length) {
            self.wizard.message = action.message;
            self.game.messageTick = tick;
        }
        else {
            self.wizard.message = nil;
        }
    }
    
    else if (action.clearMessage) {
        self.wizard.message = nil;
    }
    
    if (action.spell) {
        self.game.lastSpellCast = action.spell;
        [self.delegate aiDidCastSpell:action.spell];
    }
    
    if (action.timeRequired) {
        self.game.lastTimeRequired = action.timeRequired;
    }
    
    // TODO: record the timeRequired as a cooldown or something
}

-(void)setWizardHealth:(NSInteger)health {
    BOOL lostMatch = (health == 0);
    _wizardHealth = health;
    if (lostMatch) [self runEndActions:NO];
}

-(void)setOpponentHealth:(NSInteger)health {
    BOOL wonMatch = (health == 0);
    _opponentHealth = health;
    if (wonMatch) [self runEndActions:YES];
}


@end
