//
//  SpellSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellSprite.h"
#import "cocos2d.h"

@interface SpellSprite ()
@property (nonatomic, strong) Units * units;
@property (nonatomic, strong) CCSprite * skin;
@end

@implementation SpellSprite


-(id)initWithSpell:(Spell*)spell units:(Units *)units {
    if ((self=[super init])) {
        self.spell = spell;
        self.units = units;
        
        self.skin = [CCSprite spriteWithFile:@"fireball-1.png"];
        [self addChild:self.skin];
        
        spell.delegate = self;
        
    }
    return self;
}

-(void)didUpdateForRender {
    [self render];
}

-(void)render {
    self.position = ccp([self.units toX:self.spell.position], self.units.zeroY);
}

@end
