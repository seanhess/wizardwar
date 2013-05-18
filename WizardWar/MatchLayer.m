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
#import "SpellFireball.h"
#import "SpellEarthwall.h"

@interface MatchLayer () <CCTouchOneByOneDelegate, MatchDelegate>
@property (nonatomic, strong) Match * match;
@property (nonatomic, strong) Units * units;
@property (nonatomic, strong) NSMutableArray * spellSprites;

@property (nonatomic, strong) NSString * matchId;
@property (nonatomic, strong) NSString * playerName;

@property (nonatomic, strong) CCLabelTTF * label;
@property (nonatomic, strong) CCSprite * background;

@end

@implementation MatchLayer

-(id)initWithMatchId:(NSString*)matchId playerName:(NSString*)playerName {
    if ((self = [super init])) {
        self.matchId = matchId;
        self.playerName = playerName;
        NSLog(@"PLAYER NAME %@", self.playerName);
        
        // background
//        self.background = [CCSprite spriteWithCGImage:[UIImage imageNamed:@""] key:<#(NSString *)#>]
        self.background = [CCSprite spriteWithFile:@"background-cave.png"];
        self.background.anchorPoint = ccp(0,0);
        [self addChild:self.background];
        
        // I need to join. Am I 1st player or 2nd player?
        // Hmm... I need to know
        
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        Player * currentPlayer = [Player new];
        currentPlayer.name = playerName;
        
        self.match = [[Match alloc] initWithId:self.matchId currentPlayer:currentPlayer];
        self.match.delegate = self;
        
        self.spellSprites = [NSMutableArray array];
        
        CGFloat zeroY = 100;
        CGFloat wizardOffset = 75;
        self.units = [[Units alloc] initWithZeroY:zeroY min:wizardOffset max:self.contentSize.width-wizardOffset];
        
        self.label = [CCLabelTTF labelWithString:@"Ready" fontName:@"Marker Felt" fontSize:36];
        self.label.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        [self addChild:self.label];
            
        [self scheduleUpdate];
    }
    return self;
}

- (void)onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

//-(void)draw {
//    
//}

-(void)update:(ccTime)delta {
    //    NSLog(@"Updated %f", delta);
    
    // need to update each one
    [self.match update:delta];
}

// MATCH DELEGATE

-(void)didRemoveSpell:(Spell *)spell {
    SpellSprite * sprite = [self.spellSprites find:^BOOL(SpellSprite * sprite) {
        return (sprite.spell == spell);
    }];
    [self removeChild:sprite];
}

-(void)didAddSpell:(Spell *)spell {
    SpellSprite * sprite = [[SpellSprite alloc] initWithSpell:spell units:self.units];
    [self addChild:sprite];
    [self.spellSprites addObject:sprite];
}

-(void)matchStarted {
    self.label.visible = NO;
    [self.match.players forEach:^(Player*player) {
        CCSprite * wizard = [[WizardSprite alloc] initWithPlayer:player units:self.units];
        [self addChild:wizard];
    }];
}

-(void)matchEnded {
    self.label.visible = YES;
    self.label.string = @"Game Over";
}

-(void)drawWizard:(Player*)player {
    
}


// TOUCHES

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!self.match.started) {
        
        if (self.match.loser) {
            NSLog(@"OVER");
            [self.delegate doneWithMatch];
        }
        else {
            NSLog(@"NOT STARTED");
        }
        return;
    }
    
    CGPoint touchPoint = [touch locationInView:touch.view];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // add the spell here
    Spell * spell = nil;
    if (touchPoint.x < winSize.width/2)
        spell = [SpellEarthwall new];
    else
        spell = [SpellFireball new];
    
    [self.match castSpell:spell];
}


@end
