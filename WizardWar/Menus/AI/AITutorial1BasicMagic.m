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
#import "AITacticRandom.h"
#import "AITacticWallRenew.h"

// Dang! It's the same freaking tutorial! nooooo!

@implementation AITutorial1BasicMagic

-(id)init {
    if ((self = [super init])) {
        
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
           
           // TODO change to renew earthwall if it's low
           // or, even better, just do a random cast, and renew it frequently
           [TutorialStep message:@"I can block Fireball with a Wall of Earth."
                         tactics:@[[AITacticCast spell:Earthwall]]
                         advance:TSAdvanceSpell(Fireball)
                    allowedSpells:@[Fireball, Earthwall]],
           
           [TutorialStep message:@"Try casting Lightning instead: Earth-Air-Water."
                         tactics:@[[AITacticWallRenew createIfDead]]
                         advance:TSAdvanceDamage
                   allowedSpells:@[Fireball, Lightning, Earthwall]],
           
           // LOAD AI: Cast Icewall again if strength ever gets to 1.
           // replace action with ai
           // AI = cast an icweall
           // don't want to create if dead, because to get through fireball has to kill it
           [TutorialStep message:@"Icewall blocks lightning, but a single fireball will wipe it out."
                         tactics:@[[AITacticCast spell:Icewall], [AITacticWallRenew new]]
                         advance:TSAdvanceDamage
                   allowedSpells:@[Fireball, Lightning, Earthwall, Icewall]],
           
           // LOAD AI:
           [TutorialStep message:@"Good! Now see if you can kill me!"
                         tactics:nil
                         advance:TSAdvanceSpellAny
                   allowedSpells:@[Fireball, Lightning, Earthwall, Icewall]],
           
           // Tactics are: any time I get hit, cast a new wall.
           // New all selected: opposite as the one before? Or random?
           // AND I want to renew the wall if it gets low, at a higher priority than the other stuff :)
           [TutorialStep message:nil
                         tactics:@[[AITacticRandom spellsCastOnHit:@[Earthwall, Icewall]], [AITacticWallRenew new]]
                         advance:nil
                   allowedSpells:@[Fireball, Lightning, Earthwall, Icewall]],
        ];
    }
    return self;
}

@end
