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
#import "AITacticCast.h"

// Dang! It's the same freaking tutorial! nooooo!

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
           [TutorialStep message:@"To cast a Fireball, drag to connect Fire-Air-Heart."
                          tactics:nil
                         advance:TSAdvanceDamage
                   allowedSpells:@[Fireball]],
           
           [TutorialStep message:@"I can block Fireball with a Wall of Earth."
                         tactics:@[[AITacticCast spell:Earthwall]]
                         advance:TSAdvanceSpell(Fireball)
                    allowedSpells:@[Fireball, Earthwall]],
           
           [TutorialStep message:@"Try casting Lightning instead: Earth-Air-Water."
                         tactics:nil
                         advance:TSAdvanceDamage
                   allowedSpells:@[Fireball, Lightning, Earthwall]],
           
           // LOAD AI: Cast Icewall again if strength ever gets to 1.
           // replace action with ai
           // AI = cast an icweall
           [TutorialStep message:@"Icewall blocks lightning, but a single fireball will wipe it out."
                         tactics:@[[AITacticCast spell:Icewall]]
                         advance:TSAdvanceDamage
                   allowedSpells:@[Fireball, Lightning, Earthwall, Icewall]],
           
           // LOAD AI:
           // AI = Cast a random wall every 5 seconds?
           [TutorialStep message:@"Good! Now see if you can kill me!"
                         tactics:nil
                         advance:nil
                   allowedSpells:@[Fireball, Lightning, Earthwall, Icewall]],
                    
           
           
           
           
           // TUTORIAL 2 (keep it simple. Teach a bunch of spells?)
           // We learned Lightning and Fireball
           // Offensive spells interact too. Let's see with Summon Ogre
           // Cast a monster: Blah Blah Blah Blah
           // Try casting a monster against my lightning (TRIGGER: cast monster) (allowed: Monster)
           // :: Cast lightning (TRIGGER: take damage or collide) (casts lightning)
           // Now cast fireball against my monster (TRIGGER: cast fireball) (allowed = only fireball)
           // :: Cast Monster (SAME)
           // Now see what happens when you cast Fireball and I cast Lightning
           //
           // Tee hee.. Hack hack. *Wheeeeze* Sucker
           // Alright, let's see if you've figured it out. Eat Lightning! (TAP/CAST)

           
           
           
           
           // TUTORIAL 3 (discovery) (really just an AI)
           // I'm getting really bored telling you everything.
           // Back in my day we had to figure the spells out on our own!
           // I've unlocked all the spells, see if you can kill me!
           // You'll have to discover a new spell to do it.
           // Bring it on!

           // Everything is in your spellbook, so go check it out!??
           
           
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
