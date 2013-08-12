//
//  PracticeModeAIService.m
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PracticeModeAIService.h"
#import "Spell.h"
#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellVine.h"
#import "SpellWindblast.h"
#import "SpellIcewall.h"
#import "SpellFirewall.h"
#import "SpellInvisibility.h"
#import "SpellFist.h"
#import "SpellHelmet.h"
#import "SpellLevitate.h"
#import "SpellSleep.h"
#import "SpellFailHotdog.h"
#import "NSArray+Functional.h"
#import "UIColor+Hex.h"

@interface PracticeModeAIService ()
@property (nonatomic) NSInteger lastSpellTick;
@property (nonatomic) NSArray * allSpells;
@property (nonatomic) BOOL stop;

@property (nonatomic) NSInteger totalSpellsCast;
@property (nonatomic) NSInteger opponentSpellsCast;

@property (nonatomic) NSTimeInterval castInterval;

@end

@implementation PracticeModeAIService
@synthesize wizard = _wizard;
@synthesize delegate = _delegate;

-(id)init {
    self = [super init];
    if (self) {
        
        self.castInterval = 3.0;
        
        Wizard * wizard = [Wizard new];
        wizard.name = @"Zorlak Bot";
        wizard.wizardType = WIZARD_TYPE_ONE;
        wizard.color = [UIColor colorFromRGB:0x005EA8];
        self.wizard = wizard;
                
        self.allSpells = @[
                           [SpellFireball class], [SpellFireball class],
                           [SpellEarthwall class],
                           [SpellIcewall class],
                           [SpellWindblast class],
                           [SpellMonster class], [SpellMonster class],
                           [SpellBubble class],
                           [SpellVine class],
                           [SpellFist class],
                           [SpellHelmet class],
                           [SpellLevitate class],
                           [SpellSleep class],
                           ];
        
        // No heal or invisibility because he's not patient tnough to let it finish
        
#ifdef DEBUG
//        self.stop = YES;
        self.allSpells = @[[SpellVine class]];
#endif
    }
    return self;
}

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    if (self.stop) return;
    if (self.totalSpellsCast >= self.opponentSpellsCast) return;
    // interval is seconds per tick
    float ticksPerSecond = 1/interval;
    NSInteger castTickInterval = self.castInterval*ticksPerSecond;
    
    if (self.lastSpellTick + castTickInterval < currentTick) {
        self.lastSpellTick = currentTick;
        self.totalSpellsCast+=1;
        [self.delegate aiDidCastSpell:[self randomSpell]];
//        self.stop = YES;
    }
}

-(Spell*)randomSpell {
    Class SpellType = [self.allSpells randomItem];
    return [SpellType new];
}

-(void)opponent:(Wizard*)wizard didCastSpell:(Spell*)spell atTick:(NSInteger)tick {
    self.opponentSpellsCast += 1;
    self.lastSpellTick = tick-15;
}

@end
