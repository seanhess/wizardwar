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
#import "AITCast.h"
#import "AITWallRenew.h"
#import "AITCastOnHit.h"

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
                            demo:Fireball
                         tactics:nil
                         advance:TSAdvanceSpell(Fireball)
                   allowedSpells:@[Fireball]],
           
           // TODO change to renew earthwall if it's low
           // or, even better, just do a random cast, and renew it frequently
           [TutorialStep message:@"Blocked! Hah!"
                            demo:nil
                         tactics:@[[AITCast spell:Earthwall]]
                         advance:TSAdvanceTap
                    allowedSpells:@[]],
           
           [TutorialStep message:@"Try casting Lightning Orb instead: Earth-Air-Water."
                            demo:Lightning
                         tactics:@[[AITWallRenew createIfDead]]
                         advance:TSAdvanceSpell(Lightning)
                   allowedSpells:@[Fireball, Lightning]],
           
           [TutorialStep message:nil
                            demo:nil
                         tactics:@[[AITWallRenew createIfDead]]
                         advance:TSAdvanceDamage
                   allowedSpells:@[Fireball, Lightning]],
           
           [TutorialStep message:@"Oof! Now try to defeat me! Choose wisely..." disableControls:YES],

           [TutorialStep message:nil
                            demo:nil
                         tactics:@[[AITCastOnHit me:YES opponent:NO random:@[Earthwall, Icewall]], [AITWallRenew new]]
                         advance:TSAdvanceEnd
                   allowedSpells:@[Fireball, Lightning]],

           [TutorialStep win:@"By Merlin's beard, you've done it! Ouch!" lose:nil],
           
//           [TutorialStep modalMessage:@"Go check out the spellbook to see what you've unlocked!"],

        ];
    }
    return self;
}

@end
