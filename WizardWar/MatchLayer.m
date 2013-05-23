//
//  MatchLayer.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "MatchLayer.h"
#import "cocos2d.h"
#import "MatchGroundSprite.h"
#import "WizardSprite.h"
#import "Match.h"
#import "Spell.h"
#import "SpellSprite.h"
#import "NSArray+Functional.h"
#import "NSArray+Functional.h"
#import "Elements.h"

#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellVine.h"
#import "SpellWindblast.h"
#import "SpellIcewall.h"
#import "NSArray+Functional.h"
#import "LifeManaIndicatorNode.h"

@interface MatchLayer () <CCTouchOneByOneDelegate, MatchDelegate>
@property (nonatomic, strong) Match * match;
@property (nonatomic, strong) Units * units;
@property (nonatomic, strong) CCLayer * spells;

@property (nonatomic, strong) NSString * matchId;

@property (nonatomic, strong) CCSprite * message;
@property (nonatomic, strong) CCSprite * background;

@property (nonatomic, strong) UIButton * backButton;

@property (nonatomic, strong) LifeManaIndicatorNode *player1Indicator;
@property (nonatomic, strong) LifeManaIndicatorNode *player2Indicator;

@end

@implementation MatchLayer

-(id)initWithMatch:(Match*)match size:(CGSize)size {
    if ((self = [super init])) {
        // background
        self.background = [CCSprite spriteWithFile:@"background-cave.png"];
        self.background.anchorPoint = ccp(0,0);
        [self addChild:self.background];
        
        // don't use contentSize.
        NSLog(@"TESTING %@", NSStringFromCGSize(size));
        
        // match
        self.match = match;
        self.match.delegate = self;
        [self.match addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        
        // add a layer instead!
        self.spells = [CCLayer node];
        [self addChild:self.spells];
        
        CGFloat zeroY = 100;
        CGFloat wizardOffset = 75;
        self.units = [[Units alloc] initWithZeroY:zeroY min:wizardOffset max:size.width-wizardOffset];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"messages.plist"];
        
        self.message = [[CCSprite alloc] initWithSpriteFrameName:@"msg-ready.png"];
        self.message.position = ccp(size.width/2, size.height/2);
        [self addChild:self.message];
        
        self.player1Indicator = [LifeManaIndicatorNode node];
        self.player2Indicator = [LifeManaIndicatorNode node];
        
        self.player2Indicator.position = ccp(size.width - 150, 290);
        self.player1Indicator.position = ccp(150, 290);
        
        [self addChild:self.player1Indicator];
        [self addChild:self.player2Indicator];
        
        [self scheduleUpdate];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.match && [keyPath isEqualToString:MATCH_STATE_KEYPATH]) {
        if (self.match.state == MatchStateEnded) {
            [self matchEnded];
        }
        
        else if (self.match.state == MatchStatePlaying) {
            [self matchStarted];
        }
    }
}

- (void)onExit {
    NSLog(@"Match: onExit");
}

-(void)update:(ccTime)delta {
    //    NSLog(@"Updated %f", delta);
    
    // need to update each one
    [self.match update:delta];
}

#pragma mark -  MATCH DELEGATE

-(void)didRemoveSpell:(Spell *)spell {
    SpellSprite * sprite = [NSArray array:self.spells.children find:^BOOL(SpellSprite * sprite) {
        return (sprite.spell == spell);
    }];
    [self removeChild:sprite];
}

-(void)didAddSpell:(Spell *)spell {
    SpellSprite * sprite = [[SpellSprite alloc] initWithSpell:spell units:self.units];
    [self.spells addChild:sprite];
}

-(void)matchStarted {
    self.message.visible = NO;
    [self.match.players forEach:^(Player*player) {
        CCSprite * wizard = [[WizardSprite alloc] initWithPlayer:player units:self.units];
        [self addChild:wizard];
    }];
    
    self.player1Indicator.player = self.match.players[0];
    self.player2Indicator.player = self.match.players[1];
}

-(void)matchEnded {
//    self.pentagramViewController.view.hidden = YES;
    if (self.match.currentPlayer.state == PlayerStateDead){
        [self.message setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"msg-you-lose.png"]];
        
    } else {
        [self.message setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"msg-you-won.png"]];
    }
    self.message.visible = YES;
}

-(void)didUpdateHealthAndMana
{
    [self.player1Indicator updateFromPlayer];
    [self.player2Indicator updateFromPlayer];
}

- (void)dealloc {
    NSLog(@"Match: dealloc%@", self);
}

@end
