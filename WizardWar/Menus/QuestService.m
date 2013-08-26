//
//  QuestService.m
//  WizardWar
//
//  Created by Sean Hess on 8/23/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "QuestService.h"
#import "QuestLevel.h"
#import "ObjectStore.h"
#import "AITutorial1BasicMagic.h"
#import "AITutorial2Counters.h"
#import "AITutorial3Discovery.h"
#import "AIOpponentDummy.h"
#import "UserService.h"
#import "Achievement.h"
#import "NSArray+Functional.h"
#import "AITWallAlways.h"
#import "AITDelay.h"
#import "AITEffectRenew.h"
#import "PELevitate.h"
#import "AITCastOnClose.h"
#import "AITPerfectCounter.h"
#import "AITCounterExists.h"
#import "AIOpponentFactory.h"
#import "AITWaitForCast.h"
#import "AITMaybe.h"

#define QUEST_LEVEL_ENTITY @"QuestLevel"

@interface QuestService ()
@end

@implementation QuestService
+ (QuestService*)shared {
    static QuestService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QuestService alloc] init];
        
    });
    return instance;
}

-(id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (NSArray*)finishedQuest:(QuestLevel*)questLevel didWin:(BOOL)didWin {
    
    NSMutableArray * achievements = [NSMutableArray array];
    BOOL wasMastered = questLevel.isMastered;
    
    questLevel.gamesTotal += 1;
    if (didWin) questLevel.gamesWins += 1;
    
    // Increase levels and stuff!
    User * currentUser = [UserService.shared currentUser];
    
    if (questLevel.level >= currentUser.questLevel) {
        currentUser.questLevel = questLevel.level+1;
    }
    
    if (questLevel.wizardLevel > currentUser.wizardLevel) {
        currentUser.wizardLevel += 1;
        [achievements addObject:[Achievement wizardLevel:currentUser]];
    }
    
    if (questLevel.isMastered > wasMastered) {
        [achievements addObject:[Achievement questMastered:questLevel]];
    }
        
    // TODO return achievements!
    return achievements;
}

- (BOOL)isLocked:(QuestLevel*)questLevel user:(User*)user {
    return (user.questLevel < questLevel.level);
}

- (BOOL)hasPassedTutorials:(User*)user {
    return user.questLevel >= QUEST_LEVEL_PAST_TUTORIAL;
}

- (QuestLevel*)levelWithName:(NSString *)name {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:QUEST_LEVEL_ENTITY];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    QuestLevel * level = [ObjectStore.shared requestLastObject:request];
    if (!level) {
        level = [ObjectStore.shared insertNewObjectForEntityForName:QUEST_LEVEL_ENTITY];
        level.name = name;
    }
    return level;
}

- (void)deleteAllData {
    // don't need to do anything!
    [self.allQuestLevels forEach:^(QuestLevel*level) {
        [ObjectStore.shared.context deleteObject:level];
    }];
}

- (NSArray*)allQuestLevels {
    
    const NSTimeInterval EasyReactionTime = 0.8;
    const NSTimeInterval MediumReactionTime = 0.5;
    const NSTimeInterval HardReactionTime = 0.1;
    
    const NSInteger EasyQuestLevel = 3;
    const NSInteger MediumQuestLevel = 4;
    const NSInteger HardQuestLevel = 5;
    
    const NSInteger EasyWizardLevel = 6;
    const NSInteger MediumWizardLevel = 8;
    const NSInteger HardWizardLevel = 10;
    
    
    QuestLevel * tutorial1 = [self levelWithName:@"Tutorial - Using Magic"];
    tutorial1.level = 0;
    tutorial1.wizardLevel = 2;
    tutorial1.ai = [AIOpponentFactory withType:[AITutorial1BasicMagic class]];
    
    QuestLevel * tutorial2 = [self levelWithName:@"Tutorial - Counterspells"];
    tutorial2.level = 1;
    tutorial2.wizardLevel = 3;
    tutorial2.ai = [AIOpponentFactory withType:[AITutorial2Counters class]];

    QuestLevel * tutorial3 = [self levelWithName:@"Tutorial - Discovery"];
    tutorial3.level = 2;
    tutorial3.wizardLevel = 4;
    tutorial3.ai = [AIOpponentFactory withType:[AITutorial3Discovery class]];
    
    QuestLevel * dummy = [self levelWithName:@"Practice Dummy"];
    dummy.level = 0;
    dummy.wizardLevel = 0;
    dummy.ai = [AIOpponentFactory withType:[AIOpponentDummy class]];
    
    
    
    
    
    
    // Like the old practice mode guy
    // He wouldn't cast until you did?
    // What about a guy that is allowed to cast as soon as you have?
    // imagine a level for a first time player.
    // has pretty much all the spells
    QuestLevel * random = [self levelWithName:@"Ian the Inspecific"];
    random.level = EasyQuestLevel;
    random.wizardLevel = EasyWizardLevel;
    random.ai = [AIOpponentFactory withColor:0x0 tactics:^{
        return @[
            [AITWaitForCast random:@[Fireball, Lightning, Windblast, Bubble, Earthwall, Icewall, Firewall, Helmet, Monster, Levitate, Sleep]],
        ];
    }];
    
    
    
    // he's really slow
    // he starts out too fast!
    QuestLevel * old = [self levelWithName:@"Alatar the Anchient"];
    old.level = EasyQuestLevel;
    old.wizardLevel = EasyWizardLevel;
    old.ai = [AIOpponentFactory withColor:0x0 tactics:^{
        return @[
            [AITWallAlways walls:@[Firewall, Icewall] reactionTime:3.0],
            [AITDelay random:@[Lightning, Windblast, Heal, Invisibility, Earthwall, Rainbow, Bubble, Fireball, Bubble, Monster] reactionTime:3.0],
        ];
    }];
    
    
    
    
    QuestLevel * air = [self levelWithName:@"Aeres the Aeromancer"];
    air.level = EasyQuestLevel;
    air.wizardLevel = EasyWizardLevel;
    air.ai = [AIOpponentFactory withColor:0x0 tactics:^{
        return @[
             [AITDelay random:@[Fist, Lightning, Windblast] reactionTime:EasyReactionTime],
        ];
    }];
    
        
    
    // I don't really want to name them in two places :(
    QuestLevel * jumper = [self levelWithName:@"Fionnghal the Flying"];
    jumper.level = EasyQuestLevel;
    jumper.wizardLevel = EasyWizardLevel;
    jumper.ai = [AIOpponentFactory withColor:0x0 tactics:^{
        return @[
            [AITEffectRenew effect:[PELevitate new] spell:Levitate],
            [AITDelay random:@[Monster, Vine, Monster, Lightning] reactionTime:EasyReactionTime],
        ];
    }];
    
    

    
    // this guy is an idiot. he's way too easy to kill :)
    QuestLevel * fire = [self levelWithName:@"Pennar the Pyromancer"];
    fire.level = MediumQuestLevel;
    fire.wizardLevel = MediumWizardLevel;
    fire.ai = [AIOpponentFactory withColor:0xF23953 tactics:^{
        return @[
            [AITWallAlways walls:@[Firewall]],
            [AITDelay random:@[Fireball, Fireball, Windblast] reactionTime:HardReactionTime], // he's harder with windblast
        ];
        // MAYBE: add counter windblast instead?
    }];
    
    // If they have an icewall, cast Fireball
    // otherwise, cast sleep
    // If they cast icewall, then bubble. what can he do?
    // If there is a bubble coming towards him
    QuestLevel * sleeper = [self levelWithName:@"Seren the Somnomancer"];
    sleeper.level = MediumQuestLevel;
    sleeper.wizardLevel = MediumWizardLevel;
    sleeper.ai = [AIOpponentFactory withColor:0x0 tactics:^{
        return @[
         [AITDelay random:@[Sleep] reactionTime:MediumReactionTime],
         [AITCounterExists counters:@{Icewall:Monster, Bubble:Windblast}],
         ];
    }];
    

    QuestLevel * earth = [self levelWithName:@"Talfan the Terramancer"];
    earth.level = MediumQuestLevel;
    earth.wizardLevel = MediumWizardLevel;
    earth.ai = [AIOpponentFactory withColor:0x0 tactics:^{
        return @[
                 [AITWallAlways walls:@[Earthwall]],
                 [AITDelay random:@[Monster, Helmet, Monster, Vine] reactionTime:HardReactionTime],
                 ];
    }];
    

    
    QuestLevel * jumper2 = [self levelWithName:@"Fionnghal Returns"];
    jumper2.level = HardQuestLevel;
    jumper2.wizardLevel = HardWizardLevel;
    jumper2.ai = [AIOpponentFactory withColor:0x0 tactics:^{
        return @[
                 [AITCastOnClose distance:20.0 highSpell:Helmet lowSpell:Levitate],
                 [AITDelay random:@[Monster, Chicken, Vine, Monster, Lightning] reactionTime:HardReactionTime],
                 ];
    }];
    
    
    // Geez, this guy is hard.  Slow him down?
    QuestLevel * spam = [self levelWithName:@"Belgarath the Bold"];
    spam.level = HardQuestLevel;
    spam.wizardLevel = HardWizardLevel;
    spam.ai = [AIOpponentFactory withColor:0x0 tactics:^{
        return @[
                 [AITDelay random:@[Fireball, Lightning, Monster] reactionTime:HardReactionTime],
                 ];
    }];
    
    
    
    
    return @[
        tutorial1,
        tutorial2,
        tutorial3,
        dummy,
        
        // LIGHT MEDIUM
        old,
        random,
        air,
        jumper,

        // MEDIUM
        fire,
        earth,
        sleeper,
        
        // HARD
        jumper2,
        spam,        
        
    ];
    
/*
 
 
 5 Elemental guys. Similar programming, different spells. 
 Summoner. 
 Sleeper. he never even kills you!
 Spammers: offensive, they just chuck things at you quickly. 
 
 You don't need a whole list, just start making them!
 
 
 
 (don't worry about levels at first? Just make them?)
 (make functions, so you can mix/match. Like a L3 defense routine vs a L2 one)
√Pyromancer: spams fire everything (√)
 Counterman: always tries to reflect everything
 The Grand Wizard: try to make him awesome
 Windman: tries to make huge fireballs
 Cheater: spams random spells like crazy
 The Jerk: just hides. Really hard to kill. Just invisible all the time.
 Spam Monster:
 Spam Lightning:
 Spam Fireball:
 Spam all 3 offensively: ooh hard.
 Sleepy head: tries to get you to fall asleep forever
 Summoner: summons chicken, monster, vine, etc.
 Flying Jim: really good at dodging with levitate. Could make him drop back down to dodge too?

 The black mage: only uses evil spells?
 Simple combos: alternate earthwall / monster
 Attack counters: offensive counters. Always does the attack counters.
 

 Teddy
 Undies
 Hotdog
 Chicken
 Rainbow
 CaptainPlanet
 Cthulhu
 
 Fireball       FAH  (Fire)
 Lightning      AWE  (Air)
 Fist           AHWE (Air)
 Helmet         FHE  (Earth)
 Earthwall      FEW  (Earth)
 Firewall       AFE  (Fire)
 Bubble         HWF  (Water)
 Icewall        HWE  (Water)
 Monster        HWEF (Earth)
 Vine           AWEF (Earth)
 Windblast      AWF  (Air)
 Invisibility   AHWF (Water)
 Heal           AHE  (Heart)
 Levitate       AHW  (Air)
 Sleep          AHEF (Heart?)
 
 
 Elemental-based guys. Each one uses a different set of spells. 
 Earth:  Earthwall, Monster, Vine, Helmet
 Fire:   Fireball, Firewall
 Air:    Fist, Lightning, Levitate, Windblast
 Water:  Icewall, Bubble, Invisibility
 Heart:  Heal, Sleep
 
 
 Combo Guys: someone puts windblast and monsters to good use. (Throw a bubble between them to catch the firewall).
 
 Healer: any time he gets damaged, he puts up a wall, a helmet, and casts heal. too easy!
 
 Impossible man: he's amazing, but he takes a break and celebrates every once in a while
 Captain planet man. He whoops you with captain planet :) Naw, it's a secret :)
 
 
 
 
 
 
 */
    
    
    // LEVELS:
    

}

@end
