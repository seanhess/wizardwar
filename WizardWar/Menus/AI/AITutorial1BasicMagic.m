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
           [TutorialStep modalMessage:@"It's crawling with grumpy wizards though, so you're going to need to know how to fight."],
           [TutorialStep message:@"This is the elemental pentagram." disableControls:YES], // should DISABLE pentagram though
           [TutorialStep message:@"Spells are created by connecting 3 or more elements together." disableControls:YES],
           [TutorialStep message:@"To cast a Fireball, drag to connect Fire-Air-Heart."
                          tactics:nil
                         advance:TSAdvanceSpell(Fireball)
                   allowedSpells:@[Fireball]],
           
           // TODO change to renew earthwall if it's low
           // or, even better, just do a random cast, and renew it frequently
           [TutorialStep message:@"Blocked! Hah!"
                         tactics:@[[AITacticCast spell:Earthwall]]
                         advance:TSAdvanceSpell(Fireball)
                    allowedSpells:@[Fireball]],
           
           [TutorialStep message:@"Try casting Lightning Orb instead: Earth-Air-Water."
                         tactics:@[[AITacticWallRenew createIfDead]]
                         advance:TSAdvanceSpell(Lightning)
                   allowedSpells:@[Fireball, Lightning]],
           
           [TutorialStep message:nil
                         tactics:@[[AITacticWallRenew createIfDead]]
                         advance:TSAdvanceDamage
                   allowedSpells:@[Fireball, Lightning]],
           
           [TutorialStep message:@"Oof! Now try to defeat me! Choose wisely..."
                         tactics:nil
                         advance:TSAdvanceSpellAny
                   allowedSpells:@[Fireball, Lightning]],
           
           [TutorialStep message:nil
                         tactics:@[[AITacticRandom spellsCastOnHit:@[Earthwall, Icewall]], [AITacticWallRenew new]]
                         advance:TSAdvanceEnd
                   allowedSpells:@[Fireball, Lightning]],
           
           [TutorialStep message:@"By Merlin's beard, you've done it! Ouch!"
                         tactics:nil
                         advance:nil
                   allowedSpells:@[]],
        ];
    }
    return self;
}

@end
