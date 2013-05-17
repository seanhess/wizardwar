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
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat pixelsPerUnit;
@property (nonatomic) CGFloat wizardOffset;
@end

@implementation SpellSprite


-(id)initWithSpell:(Spell*)spell y:(CGFloat)y pixelsPerUnit:(CGFloat)pixelsPerUnit wizardOffset:(CGFloat)wizardOffset {
    if ((self=[super init])) {
        self.spell = spell;
        self.y = y;
        self.pixelsPerUnit = pixelsPerUnit;
        self.wizardOffset = wizardOffset;
        spell.delegate = self;
    }
    return self;
}

-(void)draw {
    ccDrawSolidRect(ccp(0, 0), ccp(self.spell.size, 40), ccc4f(0, 1, 0, 1));
}

-(void)didUpdateForRender {
    self.position = ccp(self.wizardOffset + self.spell.position * self.pixelsPerUnit, self.y);
    NSLog(@"WAHOOO %f %f", self.spell.position, self.position.x);
}

@end
