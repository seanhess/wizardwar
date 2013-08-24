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

-(id)init {
    if ((self = [super init])) {
        self.game = [AIGameState new];
        self.tactics = [NSMutableArray array];
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

-(void)simulateTick:(NSInteger)tick interval:(NSTimeInterval)interval spells:(NSArray*)spells {
    self.game.currentTick = tick;
    self.game.interval = interval;
    self.game.spells = spells;
    
    // now, loop through our tactics.
    
    if (!self.tactics.count) return;
    
    NSMutableArray * timeRequiredActions = [NSMutableArray array];
    NSInteger sumWeights = 0;
    
    for (id<AITactic>tactic in self.tactics) {
        AIAction * action = [tactic suggestedAction:self.game];
        
        if (action && action.timeRequired <= 0) {
            [self runAction:action];
        }
        
        else if (action && action.weight) {
            [timeRequiredActions addObject:action];
            sumWeights += action.weight;
        }
    }
    
    if (sumWeights == 0) return;
    
    // Now find the one we want to select
    NSInteger randomValue = arc4random() % sumWeights;
    __block NSInteger currentTotalWeight = 0;
    
    AIAction * action = [timeRequiredActions find:^BOOL(AIAction * action) {
        currentTotalWeight += action.weight;
        return currentTotalWeight > randomValue;
    }];

    [self runAction:action];
}

-(void)runAction:(AIAction*)action {
    
    NSLog(@"AI RUN ACTION %@", action);
    // How does it CLEAR the action?
    // maybe they fade on their own.
    
    if (action.message) {
        self.wizard.message = action.message;
    }
    
    if (action.spell) {
        self.game.lastSpellCast = action.spell;
        [self.delegate aiDidCastSpell:action.spell];
    }
    
    // TODO: record the timeRequired as a cooldown or something
}

@end
