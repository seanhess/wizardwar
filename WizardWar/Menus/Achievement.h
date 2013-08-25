//
//  Achievement.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuestLevel.h"
#import "User.h"
#import "SpellRecord.h"

@interface Achievement : NSObject
@property (nonatomic, strong) NSString * explanation;
+(id)wizardLevel:(User*)user;
+(id)spellLevel:(SpellRecord*)record;
+(id)questMastered:(QuestLevel*)level;
@end
