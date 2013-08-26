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
    }
    return self;
}

-(void)setWizard:(Wizard *)wizard {
    _wizard = wizard;
    self.game.wizard = wizard;
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
                [self runAction:action];
            }
            
            else if (!priorityAction || action.priority > priority) {
                priority = action.priority;
                priorityAction = action;
            }
        }
    }
    
    if (priorityAction) {
        NSLog(@"(%i) %@", tick, priorityAction);
        [self runAction:priorityAction];
    }
}

-(void)runAction:(AIAction*)action {
    
//    NSLog(@"      RUN %@", action);
    // How does it CLEAR the action?
    // maybe they fade on their own.
    
    if (action.message) {
        self.wizard.message = action.message;
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

@end
