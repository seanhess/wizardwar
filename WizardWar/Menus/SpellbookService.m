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
#import "SpellEffectService.h"
#import "SpellInfo.h"
#import "UIImage+MonoImage.h"


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

-(NSString*)spellTitle:(SpellRecord*)record {
    if (record.isDiscovered) {
        return record.name;
    } else {
        return @"?";
    }
}

-(UIAlertView *)failAlertForRecord:(SpellRecord *)record {
    UIAlertView * alert;
    if (!record.isDiscovered) {
        alert = [[UIAlertView alloc] initWithTitle:[self spellTitle:record] message:@"Cast this spell once to discover it" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
    }
    
    else if (!record.isUnlocked) {
        alert =[[UIAlertView alloc] initWithTitle:[self spellTitle:record] message:@"Cast this spell in 5 matches to unlock" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
    }
    
    return alert;
}

- (UIImage*)spellbookIcon:(SpellRecord*)record {
    UIImage * image = [UIImage imageNamed:[self spellIconNameByType:record.type]];
    if (!record.isUnlocked) image = [UIImage generateMonoImage:image withColor:[UIColor grayColor]];
    return image;
}

- (NSString*)spellIconName:(SpellRecord*)record {
    return [SpellSprite sheetNameForType:record.type];
}

- (NSString*)spellIconNameByType:(NSString*)type {
    return [SpellSprite sheetNameForType:type];
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
        if ([spell isAnyType:@[Fireball, Lightning, Monster, Earthwall, Firewall, Icewall]]) {
            record.castUniqueMatches = 5;
            record.castTotal = 5;
        } else if ([spell isAnyType:@[Windblast, Bubble, Invisibility, Heal, Levitate, Sleep]]) {
            record.castUniqueMatches = 1;
            record.castTotal = 1;
        }
        
        NSLog(@"SpellRecord (+) %@", record.name);
    }
    return record;
}

- (NSArray*)allSpellRecords {
    // loads the spells in the order listed in the combos array
    
    NSArray * spells = [[[SpellEffectService.shared allSpellTypes] map:^(SpellInfo * info) {
        return [Spell fromType:info.type];
    }] map:^(Spell * spell) {
        SpellRecord * record = [self recordBySpellCreate:spell];
//        record.castUniqueMatches = arc4random() % 17;
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
