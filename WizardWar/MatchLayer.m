//
//  MatchLayer.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "MatchLayer.h"
#import "cocos2d.h"
#import "WizardSprite.h"
#import "Match.h"
#import "Spell.h"
#import "SpellSprite.h"
#import "NSArray+Functional.h"
#import "Elements.h"

#import "SimpleAudioEngine.h"
#import "SpellEffectService.h"

#import "LifeIndicatorNode.h"
#import "Tick.h"
#import "FeedbackLayer.h"

#import "SpellsLayer.h"
#import "EnvironmentLayer.h"

#import <ReactiveCocoa.h>
#import "RACHelpers.h"

#define INDICATOR_PADDING_Y 40

@interface MatchLayer () <CCTouchOneByOneDelegate, MatchDelegate>
@property (nonatomic, strong) Match * match;
@property (nonatomic, strong) Units * units;
@property (nonatomic, strong) SpellsLayer * spells;
@property (nonatomic, strong) CCLayer * wizards;
@property (nonatomic, strong) CCLayer * indicators;
//@property (nonatomic, strong) FeedbackLayer * feedback;

@property (nonatomic, strong) NSString * matchId;

@property (nonatomic, strong) CCLabelTTF * debug;

@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) EnvironmentLayer * environment;

@property (nonatomic) MatchStatus matchStatus;
@property (nonatomic, strong) RACSignal * aiHideControlsSignal;

@end

@implementation MatchLayer

-(id)initWithMatch:(Match*)match size:(CGSize)size combos:(Combos *)combos units:(Units *)units {
    if ((self = [super init])) {

        self.match = match;
        self.match.delegate = self;
        
        self.units = units;
        
        [self addChild:[CCLayerColor layerWithColor:ccc4(66, 66, 66, 255)]];
        
        // Manually use the suffix, because fallbacks conflict for other stuff
        self.environment = [EnvironmentLayer new];
        [self.environment setEnvironment:match.ai.environment];
        [self addChild:self.environment];
        
        
        self.drawingLayer = [[DrawingLayer alloc] initWithUnits:units];
        [self addChild:self.drawingLayer];
       
        self.indicators = [CCLayer node];
        [self addChild:self.indicators];        
        
        self.wizards = [CCLayer node];
        [self addChild:self.wizards];
        
        self.spells = [SpellsLayer new];
        [self addChild:self.spells];
        
        // thrown off because of scale!
//        self.feedback = [FeedbackLayer node];
//        self.feedback.combos = combos;
//        self.feedback.position = ccp(self.units.center.x, self.units.center.y);
//        [self addChild:self.feedback];
        
        // LIFE MANA INDICATORS add two of them to the right spot
        LifeIndicatorNode * player1Indicator = [[LifeIndicatorNode alloc] initWithUnits:units];
        LifeIndicatorNode * player2Indicator = [[LifeIndicatorNode alloc] initWithUnits:units];
        
        player1Indicator.position = ccp(self.units.min, self.units.maxY - INDICATOR_PADDING_Y*units.spriteScaleModifier);
        player2Indicator.position = ccp(self.units.max, self.units.maxY - INDICATOR_PADDING_Y*units.spriteScaleModifier);
        
        [self.indicators addChild:player1Indicator];
        [self.indicators addChild:player2Indicator];
        
        [self scheduleUpdate];
        
        self.matchStatusSignal = [[RACAbleWithStart(self.match.status) distinctUntilChanged] filter:RACFilterExists];
        self.aiHideControlsSignal = [RACAbleWithStart(self.match.ai.hideControls) distinctUntilChanged];
        self.showControlsSignal = [RACSignal combineLatest:@[self.matchStatusSignal, self.aiHideControlsSignal]
            reduce:^(NSNumber* status, NSNumber* hideControls) {
                return @((status.intValue == MatchStatusPlaying) && !hideControls.intValue);
            }];
        
        RAC(self.matchStatus) = self.matchStatusSignal;
        RAC(self.indicators.visible) = self.showControlsSignal;
        
        // DEBUG THING
//        self.debug = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:120];
//        self.message.visible = NO;
//        self.debug.position = self.message.position;
//        [self addChild:self.debug];
    }
    return self;
}

- (void)onExit {
    NSLog(@"MatchLayer: onExit");
}

-(void)update:(ccTime)delta {
//    NSLog(@"Updated %f", delta);
    
    // need to update each one
    [self.match update:delta];
    [self.spells update:delta];
    
    for (WizardSprite * wizard in self.wizards.children) {
        [wizard update:delta];
    }
}

#pragma mark -  MATCH DELEGATE

-(void)didRemoveSpell:(Spell *)spell {
    SpellSprite * sprite = [NSArray array:self.spells.allSpellSprites find:^BOOL(SpellSprite * sprite) {
        return (sprite.spell == spell);
    }];
    [self.spells removeChild:sprite];
}

-(void)didAddSpell:(Spell *)spell {
    SpellSprite * sprite = [[SpellSprite alloc] initWithSpell:spell units:self.units];
    [self.spells addSpell:sprite];

    if([spell isType:Fireball]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"fireball.mp3"];
    }
    else if([spell isType:Earthwall]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"earthwall.mp3"];
    }
    else if ([spell isAnyType:@[Icewall, Firewall]]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"icewall.mp3"];
    }
    else if([spell isType:Vine]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"vine.mp3"];
    }
    else if([spell isType:Bubble]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"bubble.mp3"];
    }
    else if([spell isType:Monster]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"monster.mp3"];
    } 
    else if([spell isType:Windblast]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"windblast.mp3"];
    }
    else if ([spell isType:Rainbow]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"double-rainbow.mp3"];
    }
    else if ([spell isType:CaptainPlanet]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"captain-planet.mp3"];        
    }
    else if ([spell isType:Chicken]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"chicken.mp3"];
        
    }
    else {
        
    }
//    if ([spell isKindOfClass:SpellFail.class]) {
//        [[SimpleAudioEngine sharedEngine] playEffect:@"buzzer.mp3"];
//    }
}

- (void)didAddPlayer:(Wizard *)wizard {
    BOOL isCurrentWizard = (wizard == self.match.currentWizard);
    WizardSprite * sprite = [[WizardSprite alloc] initWithWizard:wizard units:self.units match:self.match isCurrentWizard:isCurrentWizard hideControls:self.aiHideControlsSignal];

    [self.wizards addChild:sprite];
}

- (void)didRemovePlayer:(Wizard *)wizard {
    WizardSprite * sprite = [NSArray array:self.wizards.children find:^BOOL(WizardSprite * sprite) {
        return (sprite.wizard == wizard);
    }];
    [self.wizards removeChild:sprite];
    // Someone disconnected
}

- (void)didTick:(NSInteger)currentTick {
    self.debug.string = [NSString stringWithFormat:@"%i", (int)(currentTick * TICK_INTERVAL)];
}

- (void)setMatchStatus:(MatchStatus)status {
    self.spells.visible = (self.match.status == MatchStatusPlaying);
    
    if (self.match.status == MatchStatusPlaying) {
        // assign wizards to indicators
        NSArray * wizards = self.match.sortedPlayers;
        [wizards forEachIndex:^(int i) {
            // view can data-bind to player
            LifeIndicatorNode * node = [self.indicators.children objectAtIndex:i];
            Wizard * wizard = wizards[i];
            node.player = wizard;
        }];
    }
    
    if (self.match.status == MatchStatusEnded) {
//        if (self.match.currentWizard.state == WizardStatusDead)
//            messageFrameName = @"msg-you-lose.png";
//        else
//            messageFrameName = @"msg-you-won.png";
    }
}

- (void)dealloc {
    NSLog(@"MatchLayer: dealloc%@", self);
}

@end
