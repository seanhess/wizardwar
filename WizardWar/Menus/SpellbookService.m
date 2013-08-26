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
#import "SpellEffect.h"
#import "Achievement.h"
#import "UserService.h"

@interface SpellbookService ()
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

-(NSString*)levelString:(SpellbookLevel)level {
    if (level == SpellbookLevelAdept) return @"Apprentice";
    else if (level == SpellbookLevelNovice) return @"Noob";
    else if (level == SpellbookLevelMaster) return @"Master";
    else return @"Noob";
}

-(NSString*)spellTitle:(SpellRecord*)record {
    if (record.isDiscovered || record.isUnlocked) {
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

- (NSArray*)finishedMatch:(NSMutableArray*)spellHistory didWin:(BOOL)didWin {
    
    NSMutableArray * achievements = [NSMutableArray array];
    User * currentUser = [UserService.shared currentUser];

    // now go through and store everything!
    // Group them by spell cast
    NSMutableDictionary * totals = [NSMutableDictionary dictionary];
    [spellHistory forEach:^(NSString * spellType) {
        NSNumber * spellTotal = totals[spellType];
        if (!spellTotal) spellTotal = @(0);
        spellTotal = @(spellTotal.intValue+1);
        totals[spellType] = spellTotal;
    }];
    
    // they  might not be CREATED yet
    for (NSString * type in totals) {
        SpellRecord * record = [self recordByType:type];
        SpellbookLevel beforeLevel = record.level;
        record.castTotal += [totals[type] intValue];
        record.castMatchesTotal += 1;
        if (didWin) record.castMatchesWins += 1;
        if (record.level > beforeLevel) {
            [achievements addObject:[Achievement spellLevel:record]];
            if (record.level > SpellbookLevelNovice) {
                currentUser.wizardLevel += 1;
                [achievements addObject:[Achievement wizardLevel:currentUser]];
            }
        }
    }
    
    

    return achievements;
}







- (void)deleteAllData {
    // don't need to do anything!
    [self.allSpellRecords forEach:^(SpellRecord*record) {
        [ObjectStore.shared.context deleteObject:record];
    }];
}






- (SpellRecord*)recordByType:(NSString*)type {
    SpellRecord * record = [ObjectStore.shared requestLastObject:[self requestByType:type]];
    if (!record) {
        SpellInfo * info = [SpellEffectService.shared infoForType:type];
        record = [ObjectStore.shared insertNewObjectForEntityForName:@"SpellRecord"];
        record.type = type;
        record.name = info.name;
        
        // unlock all spells taught in the first tutorials
        if ([Spell type:type isAnyType:@[Fireball, Lightning, Monster, Earthwall, Firewall, Icewall]]) {
            record.unlock = YES;
        }
        
        // DEBUG STUFF
        //        record.castTotal = 0;
        //        record.castUniqueMatches = 0;
        //        if ([spell isType:Cthulhu]) {
        //            record.castUniqueMatches = 10;
        //        }
        
        NSLog(@"SpellRecord (+) %@", record.name);
    }
//    record.unlock = YES;
//    record.castMatchesTotal = 4;
    
    return record;
}

- (NSArray*)allSpellRecords {
    // loads the spells in the order listed in the combos array
    
    NSArray * spells = [[SpellEffectService.shared allSpellTypes] map:^(SpellInfo * info) {
        SpellRecord * record = [self recordByType:info.type];
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
