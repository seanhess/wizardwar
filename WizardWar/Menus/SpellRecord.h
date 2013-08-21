//
//  SpellRecord.h
//  WizardWar
//
//  Created by Sean Hess on 8/19/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SpellInfo.h"

typedef enum SpellbookLevel {
    SpellbookLevelNone,
    SpellbookLevelNovice,
    SpellbookLevelAdept,
    SpellbookLevelMaster,
} SpellbookLevel;


@interface SpellRecord : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t castTotal;
@property (nonatomic) int16_t castUniqueMatches;
@property (nonatomic, readonly) SpellbookLevel level;
@property (nonatomic, readonly) CGFloat progress;
@property (nonatomic, readonly) BOOL isDiscovered;
@property (nonatomic, readonly) BOOL isUnlocked;
@property (nonatomic, readonly) SpellInfo * info;

@end
