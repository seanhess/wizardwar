//
//  AITutorial1BasicMagic.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITutorial1BasicMagic.h"
#import "UIColor+Hex.h"
#import "EnvironmentLayer.h"
#import "SpellInfo.h"

@implementation AITutorial1BasicMagic

-(id)init {
    if ((self = [super init])) {
        
        self.environment = ENVIRONMENT_CASTLE;
        
        self.steps = @[
           [TutorialStep modalMessage:@"Welcome to Wizardland, the most magical place in all the world!"],
           [TutorialStep modalMessage:@"It's crawling with grumpy wizards though, so you're going to need to know how to duel."],
           [TutorialStep modalMessage:@"First, let's cast a spell."],
           [TutorialStep message:@"This is the elemental pentagram." disableControls:YES], // should DISABLE pentagram though
           [TutorialStep message:@"Spells are created by connecting 3 or more elements together." disableControls:YES],
           [TutorialStep message:@"To cast a Fireball, drag to connect Fire, Air, and Heart." allowedSpells:@[Fireball]],
        ];
        
        [self loadStep:0];
    }
    return self;
}

/* SCRIPT--------------------
 
1. shows just you and the other wizard
 
    Tutorial Steps: 
     √ hide the pentagram
     √ remove help
     √ hide the life indicators
     √ hide the message
     √ show a speech bubble
 
    // Each tutorial step:
        // some bubble text.
        // an advance condition: tapping, casting a certain spell, etc
        // show controls
        // allowed spells
        // AI algorithm to use (can switch in the middle of a game!). can cast spells, etc

    // Incorrect action response? Naw, just say "not allowed" or something
 
STEPS
 
1. "Welcome to Wizardland, the most magical place in all the world!"
2. "It's crawling with grumpy wizards though, so you're going to need to know how to duel".
3. "First, let's cast a spell." .... "This is the elemental pentagram".
4. "Spells are created by connecting 3 or more elements together"
5. "To cast a Fireball, drag to connect Fire, Air, and Heart."
 - cast a fireball
6.
 
    "Easy there buddy, we'll learn those later on." / "To cast a Fireball, drag to connect Fire, Air, and Heart."
    "You did it! That took away some of my health.... "
 
 */

@end
