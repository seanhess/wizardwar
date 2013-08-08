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
#import "NSArray+Functional.h"
#import "Elements.h"

#import "SimpleAudioEngine.h"
#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellVine.h"
#import "SpellWindblast.h"
#import "SpellIcewall.h"
#import "SpellFailRainbow.h"
#import "SpellFailChicken.h"

#import "NSArray+Functional.h"
#import "LifeIndicatorNode.h"
#import "Tick.h"
#import "FeedbackLayer.h"
#import "DrawingLayer.h"

#import <ReactiveCocoa.h>

#define INDICATOR_PADDING_Y 40

@interface MatchLayer () <CCTouchOneByOneDelegate, MatchDelegate>
@property (nonatomic, strong) Match * match;
@property (nonatomic, strong) Units * units;
@property (nonatomic, strong) CCLayer * spells;
@property (nonatomic, strong) CCLayer * players;
@property (nonatomic, strong) CCLayer * indicators;
//@property (nonatomic, strong) FeedbackLayer * feedback;

@property (nonatomic, strong) NSString * matchId;

@property (nonatomic, strong) CCSprite * background;

@property (nonatomic, strong) CCLabelTTF * debug;

@property (nonatomic, strong) UIButton * backButton;

@property (nonatomic, strong) DrawingLayer * drawingLayer;

@end

@implementation MatchLayer

-(id)initWithMatch:(Match*)match size:(CGSize)size combos:(Combos *)combos units:(Units *)units {
    if ((self = [super init])) {
        // background
        
        self.units = units;
        
        [self addChild:[CCLayerColor layerWithColor:ccc4(66, 66, 66, 255)]];
        
        self.background = [CCSprite spriteWithFile:@"background-cave.png"];
        self.background.anchorPoint = ccp(0,0);
        [self addChild:self.background];
        
        __weak MatchLayer * wself = self;
        
        // match
        // TODO: MatchLayer should create match if it is the delegate
        self.match = match;
        self.match.delegate = self;
        
//        self.drawingLayer = [DrawingLayer new];
//        [self addChild:self.drawingLayer];
       
        self.indicators = [CCLayer node];
        [self addChild:self.indicators];        
        
        self.players = [CCLayer node];
        [self addChild:self.players];
        
        self.spells = [CCLayer node];
        [self addChild:self.spells];
        
        
        // thrown off because of scale!
//        self.feedback = [FeedbackLayer node];
//        self.feedback.combos = combos;
//        self.feedback.position = ccp(self.units.center.x, self.units.center.y);
//        [self addChild:self.feedback];
        
        // LIFE MANA INDICATORS add two of them to the right spot
        LifeIndicatorNode * player1Indicator = [LifeIndicatorNode node];
        LifeIndicatorNode * player2Indicator = [LifeIndicatorNode node];
        
        player1Indicator.match = self.match;
        player2Indicator.match = self.match;
        
        player1Indicator.position = ccp(self.units.min, self.units.maxY - INDICATOR_PADDING_Y);
        player2Indicator.position = ccp(self.units.max, self.units.maxY - INDICATOR_PADDING_Y);
        
        [self.indicators addChild:player1Indicator];
        [self.indicators addChild:player2Indicator];
        
        [self scheduleUpdate];
        
        [[RACAble(self.match.status) distinctUntilChanged] subscribeNext:^(id value) {
            [wself renderMatchStatus];
        }];
        
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
    
    for (SpellSprite * spell in self.spells.children) {
        [spell update:delta];
    }
}

#pragma mark -  MATCH DELEGATE

-(void)didRemoveSpell:(Spell *)spell {
    SpellSprite * sprite = [NSArray array:self.spells.children find:^BOOL(SpellSprite * sprite) {
        return (sprite.spell == spell);
    }];
    [self.spells removeChild:sprite];
}

-(void)didAddSpell:(Spell *)spell {
    SpellSprite * sprite = [[SpellSprite alloc] initWithSpell:spell units:self.units];
    [self.spells addChild:sprite];
    
    if([spell isMemberOfClass: [SpellFireball class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"fireball.mp3"];
    } else if([spell isMemberOfClass: [SpellEarthwall class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"earthwall.mp3"];
    } else if([spell isMemberOfClass: [SpellVine class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"vine.mp3"];
    } else if([spell isMemberOfClass: [SpellBubble class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"bubble.mp3"];
    } else if([spell isMemberOfClass: [SpellIcewall class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"icewall.mp3"];
    } else if([spell isMemberOfClass: [SpellMonster class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"monster.mp3"];
    } else if([spell isMemberOfClass: [SpellWindblast class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"windblast.mp3"];
    } else if (spell.class == SpellFailRainbow.class) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"double-rainbow.mp3"];
    } else if (spell.class == SpellFailChicken.class) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"chicken.mp3"];
    }
//    if ([spell isKindOfClass:SpellFail.class]) {
//        [[SimpleAudioEngine sharedEngine] playEffect:@"buzzer.mp3"];
//    }
}

- (void)didAddPlayer:(Wizard *)wizard {
    BOOL isCurrentWizard = (wizard == self.match.currentWizard);
    WizardSprite * sprite = [[WizardSprite alloc] initWithWizard:wizard units:self.units match:self.match isCurrentWizard:isCurrentWizard];

    [self.players addChild:sprite];
}

- (void)didRemovePlayer:(Wizard *)wizard {
    WizardSprite * sprite = [NSArray array:self.players.children find:^BOOL(WizardSprite * sprite) {
        return (sprite.wizard == wizard);
    }];
    [self.players removeChild:sprite];
    // Someone disconnected
}

- (void)didTick:(NSInteger)currentTick {
    self.debug.string = [NSString stringWithFormat:@"%i", (int)(currentTick * TICK_INTERVAL)];
}

- (void)renderMatchStatus {
    self.spells.visible = (self.match.status == MatchStatusPlaying);
    
    if (self.match.status == MatchStatusPlaying) {
        // assign players to indicators
        NSArray * players = self.match.sortedPlayers;
        [players forEachIndex:^(int i) {
            // view can data-bind to player
            LifeIndicatorNode * node = [self.indicators.children objectAtIndex:i];
            Wizard * player = players[i];
            node.player = player;
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
