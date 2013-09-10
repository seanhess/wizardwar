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
#import "AITMessage.h"
#import "EnvironmentLayer.h"
#import "AnalyticsService.h"

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
    if (!questLevel) return @[];
    
    NSMutableArray * achievements = [NSMutableArray array];
    BOOL wasMastered = questLevel.isMastered;
    
    questLevel.gamesTotal += 1;
    if (didWin) {
        questLevel.gamesWins += 1;
        
        [AnalyticsService event:[NSString stringWithFormat:@"quest-%i-complete", questLevel.level]];

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

- (NSString*)questButtonName:(User*)user {
    if ([self hasPassedTutorials:user]) {
        return @"Quest";
    } else {
        return @"Tutorial";
    }
    
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
    
//    const NSInteger EasyQuestLevel = 3;
//    const NSInteger MediumQuestLevel = 4;
//    const NSInteger HardQuestLevel = 5;
    
    
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
    dummy.level = 1;
    dummy.wizardLevel = 0;
    dummy.ai = [AIOpponentFactory withType:[AIOpponentDummy class]];
    
    
    
    // he's really slow
    // he starts out too fast!
    QuestLevel * old = [self levelWithName:@"Alatar the Ancient"];
    old.level = 3;
    old.wizardLevel = 6;
    old.ai = [AIOpponentFactory withColor:0xFFFFFF environment:ENVIRONMENT_EVIL_FOREST tactics:^{
        return @[
            [AITMessage withStart:@[@"What? Who goes there? Is that you Phil?", @"Has anybody seen my spectacles?"]],
            [AITMessage withCast:@[@"Zaldafrash!", @"Whoosh!"] chance:0.25],
            [AITMessage withWin:@[@"Where did you go?"]],
            [AITMessage withLose:@[@"At last, I can finally rest..."]],

            [AITWallAlways walls:@[Firewall, Icewall] reactionTime:3.0],
            [AITDelay random:@[Lightning, Windblast, Heal, Invisibility, Earthwall, Rainbow, Bubble, Fireball, Bubble, Monster] reactionTime:3.0],
        ];
    }];
    
    
    
    
    // Like the old practice mode guy
    // He wouldn't cast until you did?
    // What about a guy that is allowed to cast as soon as you have?
    // imagine a level for a first time player.
    // has pretty much all the spells
    QuestLevel * random = [self levelWithName:@"Ian the Inspecific"];
    random.level = 4;
    random.wizardLevel = 7;
    random.ai = [AIOpponentFactory new];
    random.ai.colorRGB = 0x888888;
    random.ai.environment = ENVIRONMENT_ICE_CAVE;
    random.ai.tactics = ^{
        return @[
            [AITMessage withStart:@[@"Well if it isn't another wet-behind-the-ears apprentice. I'm not a babysitter!", @"I hope you brought a change of pants.", @"Why don't you go bother someone else? Matlock is on!"]],
            [AITMessage withCastOther:@[@"Wow, did your mom teach you that spell?", @"Whatever."] chance:0.25],
            [AITMessage withCast:@[@"Avada ... Dangit!", @"Those robes are SO six-hundred fifteen"] chance:0.25],
            [AITMessage withWin:@[@"Ooh, nice innards. Noob."]],
            [AITMessage withLose:@[@"Just leave me alone, ok?"]],

            [AITWaitForCast random:@[Fireball, Lightning, Windblast, Bubble, Earthwall, Icewall, Firewall, Helmet, Monster, Levitate, Sleep]],
        ];
    };
    
    
    
    
    QuestLevel * air = [self levelWithName:@"Aeres the Aeromancer"];
    air.level = 5;
    air.wizardLevel = 8;
    air.ai = [AIOpponentFactory withColor:0x99C2E7 environment:ENVIRONMENT_CASTLE tactics:^{
        return @[
             [AITMessage withStart:@[@"Good day sir. I challenge you to a duel.", @"Are you sure you're ready?", @"You look in excellent health today. How is your family?"]],
             [AITMessage withHits:@[@"Ooh! Right in the knickers!", @"Are you alright?"] chance:0.25],
             [AITMessage withWounds:@[@"Crikey", @"That was below the belt!"] chance:0.25],
             [AITMessage withCast:@[@"Cheerio!", @"Look out sir!"] chance:0.25],
             [AITMessage withWin:@[@"Good heavens, what a violent contest.", @"Right-o! Until next time!"]],
             [AITMessage withLose:@[@"I say, well played!"]],
                 
             [AITDelay random:@[Fist, Lightning, Windblast] reactionTime:EasyReactionTime],
        ];
    }];
    
        
    
    // I don't really want to name them in two places :(
    QuestLevel * jumper = [self levelWithName:@"Fionnghal the Flying"];
    jumper.level = 6;
    jumper.wizardLevel = 10;
    jumper.ai = [AIOpponentFactory withColor:0x7E0B80 environment:ENVIRONMENT_CASTLE tactics:^{
        return @[
            [AITMessage withStart:@[@"Don't attack! I'm unarmed!", @"Someday, someone will best me. But it won't be today, and it won't be you."]],
            [AITMessage withHits:@[@""] chance:0.25],
            [AITMessage withWounds:@[@"Aww.. Come on!", @"You gotta be kidding me!", @"Darn these reflexes!"] chance:0.25],
            [AITMessage withCastOther:@[@""] chance:0.25],
            [AITMessage withCast:@[@"I have a PhD in flyingness", @"...also, I can kill you with my brain."] chance:0.4],
            [AITMessage withWin:@[@"Mastery is achieved when telling time becomes telling time what to do.", @"....I am your father.", @"I'm surrounded by idiots..."]],
            [AITMessage withLose:@[@"I... will.... Return!"]],
            

            [AITEffectRenew effect:[PELevitate new] spell:Levitate],
            [AITDelay random:@[Monster, Vine, Monster, Lightning] reactionTime:EasyReactionTime],
        ];
    }];
    
    

    
    // this guy is an idiot. he's way too easy to kill :)
    QuestLevel * fire = [self levelWithName:@"Pennar the Pyromancer"];
    fire.level = 7;
    fire.wizardLevel = 14;
    fire.ai = [AIOpponentFactory withColor:0xF23953 environment:ENVIRONMENT_CAVE tactics:^{
        return @[
            [AITMessage withStart:@[@"Me burn you now!", @"I AM FIRE MAGE! I CAST THE SPELLS THAT MAKE THE PEOPLES FALL DOWN!"]],
            [AITMessage withCast:@[@"Fire!", @"Buuuuuurrrrnnn!", @"Oooh!", @"DIE DIE DIE!"] chance:0.5],
            [AITMessage withWin:@[@"You dead! Ha ha ha ha ha ha!"]],
            [AITMessage withLose:@[@"Ouch"]],

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
    sleeper.level = 8;
    sleeper.wizardLevel = 15;
    sleeper.ai = [AIOpponentFactory withColor:0xF9D20F  environment:ENVIRONMENT_ICE_CAVE tactics:^{
        return @[
             [AITMessage withStart:@[@"A fight? How droll.", @"You woke me up for this?"]],
//             [AITMessage withHits:@[@"Good night. Mwa haa ha ha"] chance:1.00],
             [AITMessage withWounds:@[@"Where did I leave my shotgun again?"] chance:0.25],
             [AITMessage withCast:@[@"Sleep Tight!"] chance:0.5],
//             [AITMessage withCastOther:@[] chance:0.25],
             [AITMessage withWin:@[@""]],
             [AITMessage withLose:@[@"Death. What is it really, but an eternal nap?"]],
             
             [AITDelay random:@[Sleep] reactionTime:MediumReactionTime],
             [AITCounterExists counters:@{Icewall:Monster, Bubble:Windblast}],
         ];
    }];
    

    QuestLevel * earth = [self levelWithName:@"Talfan the Terramancer"];
    earth.level = 9;
    earth.wizardLevel = 17;
    earth.ai = [AIOpponentFactory withColor:0x34A44F environment:ENVIRONMENT_CAVE tactics:^{
        return @[
            [AITMessage withStart:@[@"Thou darest challenge me? This day shall be thy last!", @"Thou fool! May the earth consume thee and thy posterity FOR ALL TIME."]],
            [AITMessage withHits:@[@"Beg for mercy!", @"Thou art no match for Talfan!"] chance:0.25],
            [AITMessage withWounds:@[@"Darest thou harm me?"] chance:0.25],
            [AITMessage withCast:@[@"Witness the wrath of Talfan!", @"Bow before my power!"] chance:0.25],
            [AITMessage withCastOther:@[@"Was that an attempt at magic?", @"Thy drivel is no match for my fury!"] chance:0.25],
            [AITMessage withWin:@[@"Thine incompetence doth insult the very stones upon which you lie"]],
            [AITMessage withLose:@[@"My rage lives on. I will return!"]],

            [AITWallAlways walls:@[Earthwall]],
            [AITDelay random:@[Monster, Helmet, Monster, Vine] reactionTime:HardReactionTime],
        ];
    }];
    

    
    // Geez, this guy is hard.  Slow him down?
    QuestLevel * spam = [self levelWithName:@"Belgarath the Bold"];
    spam.level = 10;
    spam.wizardLevel = 19;
    spam.ai = [AIOpponentFactory withColor:0x0 environment:ENVIRONMENT_EVIL_FOREST tactics:^{
        return @[         
            [AITMessage withStart:@[@"Child, I can so thoroughly destroy you, your own mother will forget the day of your birth.", @"Prepare to die... Obviously!"]],
            [AITMessage withHits:@[@"Bwahahahahaha", @"That is the last mistake you shall ever make.", @"My will be done"] chance:0.25],
            [AITMessage withWounds:@[@"Inconceivable!", @"I grow tired of your games...", @"You are more useful to me dead than you are alive. Don't push your luck."] chance:0.25],
            [AITMessage withCast:@[@"Despair!", @"Take that!"] chance:0.25],
            [AITMessage withCastOther:@[@"You think that will stop me?"] chance:0.25],
            [AITMessage withWin:@[@"I. Win."]],
            [AITMessage withLose:@[@"Nooooooooooooo!"]],

            [AITDelay random:@[Fireball, Lightning, Monster] reactionTime:HardReactionTime],
        ];
    }];
    
    
    
    
    QuestLevel * jumper2 = [self levelWithName:@"Fionnghal Returns"];
    jumper2.level = 11;
    jumper2.wizardLevel = 20;
    jumper2.ai = [AIOpponentFactory withColor:0x7E0B80 environment:ENVIRONMENT_CASTLE tactics:^{
        return @[
                 
                 [AITMessage withStart:@[@"Ok, this time I'm ready!", @"You'll never take me alive!"]],
                 [AITMessage withHits:@[@"I was looking for a battle of wits, but I'm afraid you are unarmed."] chance:0.25],
                 [AITMessage withWounds:@[@"How can this be?"] chance:0.25],
                 [AITMessage withCast:@[@"Can't touch this!", @"My finger... It's... It's Glowing."] chance:0.25],
                 [AITMessage withCastOther:@[@"How vulgar."] chance:0.25],
                 [AITMessage withWin:@[@"You have much to learn."]],
                 [AITMessage withLose:@[@"Haha, my technique is perfect. My form is perfect."]],
                 
                 [AITCastOnClose distance:40.0 highSpell:Helmet lowSpell:Levitate],
                 [AITDelay random:@[Monster, Vine, Monster, Lightning] reactionTime:HardReactionTime],
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
        sleeper,        
        earth,
        
        // HARD
        spam,
        jumper2,        
        
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
