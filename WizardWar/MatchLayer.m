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

@interface MatchLayer () <CCTouchOneByOneDelegate>
@property (nonatomic, strong) Match * match;
@end

@implementation MatchLayer

-(id)init {
    if ((self = [super init])) {
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        self.match = [Match new];
        
        CCSprite * ground = [MatchGroundSprite new];
        ground.position = ccp(self.contentSize.width/2, 25);
        ground.contentSize = CGSizeMake(self.contentSize.width, 50);
        [self addChild:ground];
        
        CCSprite * wizard = [WizardSprite new];
        wizard.position = ccp(50, 75);
        wizard.contentSize = CGSizeMake(30, 30);
        [self addChild:wizard];
        
        CCSprite * wizard2 = [WizardSprite new];
        wizard2.position = ccp(self.contentSize.width - 50, 75);
        wizard2.contentSize = CGSizeMake(30, 30);
        [self addChild:wizard2];
        
        [self scheduleUpdate];
    }
    return self;
}

//-(void)draw {
//    
//}

-(void)update:(ccTime)delta {
//    NSLog(@"Updated %f", delta);
    
    // need to update each one
    [self.match update:delta];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // add the spell here
    Spell * spell = [self fakeSpell];
    [self.match.spells addObject:spell];
    SpellSprite * spellSprite = [SpellSprite new];
    spellSprite.spell = spell;
    [self addChild:spellSprite];
}

-(Spell*)fakeSpell {
    Spell * spell = [Spell new];
    spell.speed = 10;
    spell.size = 40;
    spell.created = CACurrentMediaTime();
    spell.type = SpellTypeFireball;
    return spell;
}

@end
