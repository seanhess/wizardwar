//
//  SpellbookService.h
//  WizardWar
//
//  Created by Sean Hess on 8/19/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SpellRecord.h"
#import "Spell.h"

@interface SpellbookService : NSObject
+ (SpellbookService*)shared;

- (SpellRecord*)recordByType:(NSString*)type;
- (SpellRecord*)recordBySpellCreate:(Spell*)spell;
- (NSArray*)allSpellRecords;
- (NSString*)spellIconName:(SpellRecord*)record;

- (void)mainPlayerCastSpell:(Spell*)spell inMatch:(NSString*)matchId;
- (void)finishedMatch:(NSString*)matchId;

- (NSFetchRequest*)requestAllSpells;
- (NSFetchRequest*)requestByType:(NSString*)type;

// What if I add new spells later?
// Just load the spellbook every time, it won't be that hard

@end
