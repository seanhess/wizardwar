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

@interface QuestService : NSObject
+ (QuestService*)shared;

- (BOOL)isLocked:(QuestLevel*)level user:(User*)user;

- (QuestLevel*)levelWithName:(NSString*)name;
- (NSArray*)allQuestLevels;

- (void)finishedMatch:(NSArray*)spellHistory didWin:(BOOL)didWin;
@end
