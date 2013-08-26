//
//  AITutorial2Counters.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITutorial2Counters.h"
#import "AITCast.h"
#import "AITCastOnHit.h"
#import "AITWallAlways.h"

@implementation AITutorial2Counters

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


-(id)init {
    if ((self = [super init])) {
        
        // TACTIC: immediately cast one of the spells.
        // on damage either player, cast another one
                
        self.steps = @[
           [TutorialStep modalMessage:@"You again!? I'm getting sick of your sense of entitlement!"],
           [TutorialStep modalMessage:@"Being a wizard is about more than just good looks."],
           [TutorialStep modalMessage:@"Listen: The best defense is offense. The best omlet is a mushroom."],

           [TutorialStep message:@"Why don't you Summon an Ogre: Fire-Earth-Water-Heart"
                            demo:Monster
                         tactics:nil
                         advance:TSAdvanceSpell(Monster)
                   allowedSpells:@[Monster, Firewall, Icewall, Earthwall]],

           [TutorialStep message:nil
                            demo:nil
                         tactics:@[[AITCast spell:Lightning]]
                         advance:TSAdvanceDamage
                   allowedSpells:@[Monster, Lightning, Fireball, Firewall, Icewall, Earthwall]],

           [TutorialStep message:@"Monster blows right through Lightning Orb." disableControls:YES],
           
           [TutorialStep message:@"There are some other spells that do that, but I forget which ones..." disableControls:YES],           

           [TutorialStep message:@"Go visit the Spellbook to see the spells you've discovered and what they counter." disableControls:YES],
           
           [TutorialStep message:@"I'm going to chuck magic at your face. See if you can counter it! On guard!" disableControls:YES],

           [TutorialStep message:nil
                            demo:nil
                         tactics:@[[AITCastOnHit me:YES opponent:YES random:@[Fireball, Monster, Lightning]], [AITWallAlways walls:@[Firewall, Earthwall, Icewall]]]
                         advance:TSAdvanceEnd
                   allowedSpells:@[Fireball, Lightning, Monster, Earthwall, Firewall, Icewall]],

           [TutorialStep win:@"Haha. You should have seen your face! You were all like ZOMG!"
                        lose:@"Not in the face!"],
           
//           [TutorialStep modalMessage:@"Go check out the spellbook to see what you've unlocked!"]           

           
           
           
           
           
//           [TutorialStep message:nil
//                         tactics:nil
//                         advance:nil
//                   allowedSpells:allowed],
           
           
//           // TODO change to renew earthwall if it's low
//           // or, even better, just do a random cast, and renew it frequently
//           [TutorialStep message:@"I can block Fireball with a Wall of Earth."
//                         tactics:@[[AITacticCast spell:Earthwall]]
//                         advance:TSAdvanceSpell(Fireball)
//                   allowedSpells:@[Fireball, Earthwall]],
//           
//           [TutorialStep message:@"Try casting Lightning instead: Earth-Air-Water."
//                         tactics:@[[AITacticWallRenew createIfDead]]
//                         advance:TSAdvanceDamage
//                   allowedSpells:@[Fireball, Lightning, Earthwall]],
//           
//           // LOAD AI: Cast Icewall again if strength ever gets to 1.
//           // replace action with ai
//           // AI = cast an icweall
//           // don't want to create if dead, because to get through fireball has to kill it
//           [TutorialStep message:@"Icewall blocks lightning, but a single fireball will wipe it out."
//                         tactics:@[[AITacticCast spell:Icewall], [AITacticWallRenew new]]
//                         advance:TSAdvanceDamage
//                   allowedSpells:@[Fireball, Lightning, Earthwall, Icewall]],
//           
//           // LOAD AI:
//           [TutorialStep message:@"Good! Now see if you can kill me!"
//                         tactics:nil
//                         advance:TSAdvanceSpellAny
//                   allowedSpells:@[Fireball, Lightning, Earthwall, Icewall]],
//           
//           // Tactics are: any time I get hit, cast a new wall.
//           // New all selected: opposite as the one before? Or random?
//           // AND I want to renew the wall if it gets low, at a higher priority than the other stuff :)
//           [TutorialStep message:nil
//                         tactics:@[[AITacticRandom spellsCastOnHit:@[Earthwall, Icewall]], [AITacticWallRenew new]]
//                         advance:nil
//                   allowedSpells:@[Fireball, Lightning, Earthwall, Icewall]],
       ];
    }
    return self;
}


@end
