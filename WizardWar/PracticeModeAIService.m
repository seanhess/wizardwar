//
//  PracticeModeAIService.m
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PracticeModeAIService.h"
#import "Spell.h"
#import "NSArray+Functional.h"
#import "UIColor+Hex.h"
#import "SpellEffectService.h"

@interface PracticeModeAIService ()
@property (nonatomic) NSInteger lastSpellTick;
@property (nonatomic) NSArray * allOffensive;
@property (nonatomic) NSArray * allDefensive;
@property (nonatomic) BOOL stop;

@property (nonatomic) NSInteger totalSpellsCast;
@property (nonatomic) NSInteger opponentSpellsCast;

@property (nonatomic) NSTimeInterval castInterval;

@property (nonatomic, strong) Spell * lastCastSpell;

@end

// He can cast walls for free!
// they don't count against the limit
@implementation PracticeModeAIService
@synthesize wizard = _wizard;
@synthesize opponent = _opponent;
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
                
        self.allOffensive = @[
            Fireball, Fireball,
            Windblast,
            Monster, Monster,
            Bubble,
            Lightning,
            Vine,
            Fist,
            Sleep,
        ];
        
        self.allDefensive = @[
            Earthwall,
            Icewall,
            Firewall,
            Helmet,
            Levitate,
        ];
        
        // No heal or invisibility because he's not patient tnough to let it finish
        
#ifdef DEBUG
        self.stop = YES;
        self.allOffensive = @[Fireball];
        self.allDefensive = @[Earthwall];
#endif
    }
    return self;
}

-(BOOL)isDefensive:(Spell*)spell {
    Class Found = [self.allDefensive find:^BOOL(NSString * type) {
        return [spell isType:type];
    }];
    return Found != nil;
}

-(void)castSpell:(NSArray*)fromList {
    NSString * type = [fromList randomItem];
    self.lastCastSpell = [Spell fromType:type];
    [self.delegate aiDidCastSpell:self.lastCastSpell];
#ifdef DEBUG
//    self.stop = YES;
#endif
}

// It's more like does he HAVE a wall or not?
// aaaannnd, I have no idea. 

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    if (self.stop) return;
    // interval is seconds per tick
    float ticksPerSecond = 1/interval;
    NSInteger castTickInterval = self.castInterval*ticksPerSecond;
    
    if (self.lastSpellTick + castTickInterval < currentTick) {
        self.lastSpellTick = currentTick;
        if (self.totalSpellsCast == self.opponentSpellsCast) {
            if (!self.lastCastSpell.isWall) {
                [self castSpell:self.allDefensive];
            }
        } else if (self.totalSpellsCast < self.opponentSpellsCast) {
            if ([self isDefensive:self.lastCastSpell]) {
                self.totalSpellsCast+=1;
                [self castSpell:self.allOffensive];
            } else {
                [self castSpell:self.allDefensive];
            }
        }
    }
}

-(Spell*)randomSpell {
    Class SpellType = [self.allOffensive randomItem];
    return [SpellType new];
}

-(void)opponent:(Wizard*)wizard didCastSpell:(Spell*)spell atTick:(NSInteger)tick {
    self.opponentSpellsCast += 1;
}

-(BOOL)shouldPreventSpellCast:(Spell *)spell atTick:(NSInteger)tick {
    return NO;
}

@end
