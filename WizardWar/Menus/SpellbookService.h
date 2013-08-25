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

- (NSString*)levelString:(SpellbookLevel)level;
- (NSString*)spellTitle:(SpellRecord*)record;
- (UIAlertView*)failAlertForRecord:(SpellRecord*)record;
- (UIImage*)spellbookIcon:(SpellRecord*)record;
- (NSString*)spellIconName:(SpellRecord*)record;
- (NSString*)spellIconNameByType:(NSString*)type;

- (NSArray*)allSpellRecords;
- (SpellRecord*)recordByType:(NSString*)type;

- (void)finishedMatch:(NSMutableArray*)spellHistory didWin:(BOOL)didWin;

- (NSFetchRequest*)requestAllSpells;
- (NSFetchRequest*)requestByType:(NSString*)type;

// What if I add new spells later?
// Just load the spellbook every time, it won't be that hard

@end
