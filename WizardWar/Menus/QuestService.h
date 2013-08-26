//
//  QuestService.h
//  WizardWar
//
//  Created by Sean Hess on 8/23/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuestLevel.h"
#import "User.h"

#define QUEST_LEVEL_PAST_TUTORIAL 3
#define WIZARD_LEVEL_PAST_TUTORIAL 5

@interface QuestService : NSObject
+ (QuestService*)shared;

- (BOOL)hasPassedTutorials:(User*)user;
- (BOOL)isLocked:(QuestLevel*)level user:(User*)user;

- (void)deleteAllData;

- (QuestLevel*)levelWithName:(NSString*)name;
- (NSArray*)allQuestLevels;

- (NSArray*)finishedQuest:(QuestLevel*)level didWin:(BOOL)didWin;
@end
