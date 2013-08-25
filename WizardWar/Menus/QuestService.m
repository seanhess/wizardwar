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
#import "AIOpponentDummy.h"

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

- (void)finishedMatch:(NSArray*)spellHistory didWin:(BOOL)didWin {

}

- (BOOL)isLocked:(QuestLevel*)questLevel user:(User*)user {
    return (user.questLevel < questLevel.level);
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

- (NSArray*)allQuestLevels {
    QuestLevel * tutorial1 = [self levelWithName:@"Tutorial - Using Magic"];
    tutorial1.level = 0;
    tutorial1.AIType = [AITutorial1BasicMagic class];
    tutorial1.wizardLevel = 1;
    
    QuestLevel * tutorial2 = [self levelWithName:@"Tutorial - Counterspells"];
    tutorial2.level = 0;
    tutorial2.wizardLevel = 2;
    
    QuestLevel * tutorial3 = [self levelWithName:@"Tutorial - Discovery"];
    tutorial3.level = 0;
    tutorial3.wizardLevel = 3;
    
    QuestLevel * practice = [self levelWithName:@"Practice Dummy"];
    practice.level = 0;
    practice.wizardLevel = 0;
    practice.AIType = [AIOpponentDummy class];
    
    QuestLevel * asdf = [self levelWithName:@"First Real Guy"];
    asdf.level = 1;
    asdf.wizardLevel = 1;
    
    return @[
        tutorial1,
        tutorial2,
        tutorial3,
        practice,
        asdf,
    ];
}

@end
