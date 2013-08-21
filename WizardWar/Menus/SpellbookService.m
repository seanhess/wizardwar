//
//  SpellbookService.m
//  WizardWar
//
//  Created by Sean Hess on 8/19/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellbookService.h"
#import "ObjectStore.h"
#import "Combos.h"
#import "NSArray+Functional.h"
#import "SpellSprite.h"


@interface SpellbookService ()
@property (nonatomic, strong) NSMutableDictionary * currentMatchSpellsCast;
@end

@implementation SpellbookService

+ (SpellbookService*)shared {
    static SpellbookService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SpellbookService alloc] init];
        
    });
    return instance;
}



- (NSString*)spellIconName:(SpellRecord*)record {
    Class spellClass = [Spell classFromType:record.type];
    return [SpellSprite sheetNameForClass:spellClass];
}

// Hmm... how could I tell what's important or not?
- (void)mainPlayerCastSpell:(Spell*)spell inMatch:(NSString*)matchId {
    if (!self.currentMatchSpellsCast) {
        self.currentMatchSpellsCast = [NSMutableDictionary dictionary];
    }

    NSNumber * numCastSpell = self.currentMatchSpellsCast[spell.type];
    self.currentMatchSpellsCast[spell.type] = @(numCastSpell.intValue+1);
}

- (void)finishedMatch:(NSString *)matchId {
    // now go through and store everything!
    
    for (NSString * type in self.currentMatchSpellsCast.allKeys) {
        SpellRecord * record = [self recordByType:type];
        record.castTotal += [self.currentMatchSpellsCast[type] intValue];
        record.castUniqueMatches += 1;
        
    }
    
    self.currentMatchSpellsCast = nil;
}













- (SpellRecord*)recordByType:(NSString*)type {
    SpellRecord * record = [ObjectStore.shared requestLastObject:[self requestByType:type]];
    return record;
}

- (SpellRecord*)recordBySpellCreate:(Spell *)spell {
    SpellRecord * record = [self recordByType:spell.type];
    if (!record) {
        record = [ObjectStore.shared insertNewObjectForEntityForName:@"SpellRecord"];
        record.type = spell.type;
        record.name = spell.name;
        record.castTotal = 0;
        record.castUniqueMatches = 0;
        NSLog(@"SpellRecord (+) %@", record.name);
    }
    return record;
}

- (NSArray*)allSpellRecords {
    // loads the spells in the order listed in the combos array
    
    NSArray * spells = [[[Combos allSpellClasses] map:^(Class SpellClass) {
        return [SpellClass new];
    }] map:^(Spell * spell) {
        SpellRecord * record = [self recordBySpellCreate:spell];
        record.castUniqueMatches = arc4random() % 17;
//        record.castUniqueMatches = 2;
        return record;
    }];

    return spells;
}


- (NSFetchRequest*)requestAllSpells {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"SpellRecord"];
    NSSortDescriptor * sortByType = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sortByType];
    return request;
}

- (NSFetchRequest*)requestByType:(NSString *)type {
    NSFetchRequest * request = [self requestAllSpells];
    request.predicate = [NSPredicate predicateWithFormat:@"type = %@", type];
    return request;
}

@end
