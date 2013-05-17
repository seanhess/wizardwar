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
@property (nonatomic) CGFloat wizardOffset;
@property (nonatomic) CGFloat pixelsPerUnit;
@property (nonatomic) CGFloat spellY;
@property (nonatomic, strong) NSMutableArray * spellSprites;
@end

@implementation MatchLayer

-(id)init {
    if ((self = [super init])) {
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        self.match = [[Match alloc] initWithId:@"fake"];
        self.match.delegate = self;
        
        self.spellSprites = [NSMutableArray array];
        
        self.wizardOffset = 50;
        self.pixelsPerUnit = (self.contentSize.width-2*self.wizardOffset) / 100;
        self.spellY = 50;
        
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

-(void)didRemoveSpell:(Spell *)spell {
    SpellSprite * sprite = [self.spellSprites find:^BOOL(SpellSprite * sprite) {
        return (sprite.spell == spell);
    }];
    [self removeChild:sprite];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // add the spell here
    Spell * spell = [self fakeSpell];
    [self.match addSpell:spell]; // add spell
    SpellSprite * sprite = [[SpellSprite alloc] initWithSpell:spell y:self.spellY pixelsPerUnit:self.pixelsPerUnit wizardOffset:self.wizardOffset]; // add visually
    [self addChild:sprite];
    [self.spellSprites addObject:sprite];
}

-(Spell*)fakeSpell {
    Spell * spell = [Spell new];
    spell.speed = 20;
    spell.size = 40;
    spell.created = CACurrentMediaTime();
    spell.type = SpellTypeFireball;
    return spell;
}

@end
