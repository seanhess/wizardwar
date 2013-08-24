//
//  AITutorial1BasicMagic.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITutorial1BasicMagic.h"
#import "UIColor+Hex.h"

@implementation AITutorial1BasicMagic
@synthesize wizard = _wizard;
@synthesize opponent = _opponent;
@synthesize delegate = _delegate;
@synthesize hideControls = _hideControls;

-(id)init {
    if ((self = [super init])) {
        Wizard * wizard = [Wizard new];
        wizard.name = @"Horzo the Helpful";
        wizard.wizardType = WIZARD_TYPE_ONE;
        wizard.color = [UIColor colorFromRGB:0x005EA8];
        wizard.message = @"Welcome to Wizardland!";
        self.wizard = wizard;
        self.hideControls = YES;
    }
    return self;
}

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    
}

-(void)opponent:(Wizard*)wizard didCastSpell:(Spell*)spell atTick:(NSInteger)tick {
    
}

-(BOOL)shouldPreventSpellCast:(Spell *)spell atTick:(NSInteger)tick {
    return NO;
}

-(void)tutorialDidTap {
    
}

/* SCRIPT--------------------
 
1. shows just you and the other wizard
 
    Tutorial Steps: 
     - hide the pentagram
     - remove help
     - hide the life indicators
     - hide the message
     - show a speech bubble
 
    "Welcome to Wizardland, the most magical place in all the world!"
    "It's crawling with grumpy wizards though, so you're going to need to know how to duel".
    "First, let's cast a spell." .... "This is the elemental pentagram".
    "Spells are created by connecting 3 or more elements together"
    "To cast a Fireball, drag to connect Fire, Air, and Heart."
 
    "Easy there buddy, we'll learn those later on." / "To cast a Fireball, drag to connect Fire, Air, and Heart."
 
    "You did it! That took away some of my health.... "
 

 
2. 
 
 */

@end
