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
    QuestLevel * tutorial1 = [self levelWithName:@"Tutorial 1 - Using Magic"];
    tutorial1.level = 0;
    tutorial1.ai = [AITutorial1BasicMagic new];
    
    QuestLevel * tutorial2 = [self levelWithName:@"Tutorial 2 - Counterspells"];
    tutorial2.level = 1;
    
    QuestLevel * tutorial3 = [self levelWithName:@"Tutorial 3 - Discovery"];
    tutorial3.level = 2;
    
    QuestLevel * zorlack = [self levelWithName:@"Zorlack"];
    zorlack.level = 1;
    zorlack.wizardLevel = 3;
    
    QuestLevel * asdf = [self levelWithName:@"asdf"];
    asdf.level = 2;
    asdf.wizardLevel = 4;
    
    
    return @[
        tutorial1,
        tutorial2,
        tutorial3,
        zorlack,
        zorlack,
        zorlack,
        zorlack,
       zorlack,
       zorlack,
        asdf,
    ];
}

@end
