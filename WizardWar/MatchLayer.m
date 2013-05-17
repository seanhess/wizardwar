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

@interface MatchLayer () <CCTouchOneByOneDelegate, MatchDelegate>
@property (nonatomic, strong) Match * match;
@property (nonatomic, strong) Units * units;
@property (nonatomic, strong) NSMutableArray * spellSprites;

@property (nonatomic, strong) NSString * matchId;
@property (nonatomic, strong) NSString * playerName;

@end

@implementation MatchLayer

-(id)initWithMatchId:(NSString*)matchId playerName:(NSString*)playerName {
    if ((self = [super init])) {
        self.matchId = matchId;
        self.playerName = playerName;
        NSLog(@"PLAYER NAME %@", self.playerName);
        
        // I need to join. Am I 1st player or 2nd player?
        // Hmm... I need to know
        
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        Player * currentPlayer = [Player new];
        currentPlayer.name = playerName;
        
        self.match = [[Match alloc] initWithId:self.matchId currentPlayer:currentPlayer];
        self.match.delegate = self;
        
        self.spellSprites = [NSMutableArray array];
        
        self.units = [Units new];
        self.units.wizardOffset = 50;
        self.units.pixelsPerUnit = (self.contentSize.width-2*self.units.wizardOffset) / 100;
        self.units.groundY = 75;
        
        CCSprite * ground = [MatchGroundSprite new];
        ground.position = ccp(self.contentSize.width/2, 25);
        ground.contentSize = CGSizeMake(self.contentSize.width, 50);
        [self addChild:ground];
        

            
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

-(void)matchStarted {
    [self.match.players forEach:^(Player*player) {
        CCSprite * wizard = [[WizardSprite alloc] initWithPlayer:player units:self.units];
        [self addChild:wizard];
    }];
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
        NSLog(@"NOT STARTED");
        return;
    }
    
    // add the spell here
    Spell * spell = [self fakeSpell];
    [self.match addSpell:spell]; // add spell
    SpellSprite * sprite = [[SpellSprite alloc] initWithSpell:spell units:self.units];
    [self addChild:sprite];
    [self.spellSprites addObject:sprite];
}

// starts at MY PLAYER
-(Spell*)fakeSpell {
    Spell * spell = [Spell new];
    spell.position = self.match.currentPlayer.position;
    spell.speed = 20;
    spell.size = 40;
    spell.created = CACurrentMediaTime();
    spell.type = SpellTypeFireball;
    
    NSLog(@"FAKE SPELL %@", self.match.currentPlayer);
    if (!self.match.currentPlayer.isFirstPlayer) {
        spell.speed *= -1;
    }
    
    return spell;
}

@end
