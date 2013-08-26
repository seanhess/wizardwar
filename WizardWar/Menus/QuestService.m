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
    return user.questLevel > 2;
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
    QuestLevel * tutorial1 = [self levelWithName:@"Tutorial - Using Magic"];
    tutorial1.level = 0;
    tutorial1.AIType = [AITutorial1BasicMagic class];
    tutorial1.wizardLevel = 1;
    
    QuestLevel * tutorial2 = [self levelWithName:@"Tutorial - Counterspells"];
    tutorial2.level = 1;
    tutorial2.wizardLevel = 2;
    tutorial2.AIType = [AITutorial2Counters class];

    QuestLevel * tutorial3 = [self levelWithName:@"Tutorial - Discovery"];
    tutorial3.level = 2;
    tutorial3.wizardLevel = 3;
    tutorial3.AIType = [AITutorial3Discovery class];
    
    QuestLevel * practice = [self levelWithName:@"Practice Dummy"];
    practice.level = 0;
    practice.wizardLevel = 0;
    practice.AIType = [AIOpponentDummy class];
    
    // I don't really want to name them in two places :(
    QuestLevel * jumper = [self levelWithName:@"Fionnghal the Flying"];
    jumper.level = 0;
    jumper.wizardLevel = 0;
    jumper.colorRGB = 0x0;
    jumper.tactics = @[
        [AITEffectRenew effect:[PELevitate new] spell:Levitate],
        [AITDelay random:@[Monster, Vine, Monster, Lightning]],
    ];
    
    
    QuestLevel * jumper2 = [self levelWithName:@"Fionnghal Returns"];
    jumper2.level = 0;
    jumper2.wizardLevel = 0;
    jumper2.colorRGB = 0x0;
    jumper2.tactics = @[
        [AITCastOnClose distance:20.0 highSpell:Helmet lowSpell:Levitate],
        [AITDelay random:@[Monster, Chicken, Vine, Monster, Lightning]],
    ];

    
    QuestLevel * earth = [self levelWithName:@"Talfan the Terramancer"];
    earth.level = 0;
    earth.wizardLevel = 0;
    earth.colorRGB = 0x0;
    earth.tactics = @[
        [AITWallAlways walls:@[Earthwall]],
        [AITDelay random:@[Monster, Helmet, Monster, Vine]],
    ];
    
    // WHAT WE REEALLY NEED:
    // Each QuestLevel... Hmm...
    // QuestLevel: makes an AIOpponent, sets the wizard stuff, sets the tactics.
    // color, name, tactics

    return @[
             tutorial1,
             tutorial2,
             tutorial3,
             practice,
             jumper,
             jumper2,
             earth,
             ];
    
/*
 
 
 5 Elemental guys. Similar programming, different spells. 
 Summoner. 
 Sleeper. he never even kills you!
 Spammers: offensive, they just chuck things at you quickly. 
 
 You don't need a whole list, just start making them!
 
 
 
 (don't worry about levels at first? Just make them?)
 (make functions, so you can mix/match. Like a L3 defense routine vs a L2 one)
 Pyromancer: spams fire everything
 Counterman: always tries to reflect everything
 The Grand Wizard: try to make him awesome
 Windman: tries to make huge fireballs
 Cheater: spams random spells like crazy
 The Jerk: just hides. Really hard to kill. Just invisible all the time.
 Spam Monster:
 Spam Lightning:
 Spam Fireball:
 Spam all 3 offensively:
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
 
 Healer: any time he gets damaged, he puts up a wall, a helmet, and casts heal.
 
 Impossible man: he's amazing, but he takes a break and celebrates every once in a while
 Captain planet man. He whoops you with captain planet :) Naw, it's a secret :)
 
 
 
 
 
 
 */
    
    
    // LEVELS:
    

}

@end
