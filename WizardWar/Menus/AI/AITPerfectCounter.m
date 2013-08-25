//
//  AITacticPerfectCounter.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITPerfectCounter.h"
#import "NSArray+Functional.h"
#import "Units.h"

@interface AITPerfectCounter ()
@property (nonatomic, strong) NSMutableDictionary* alreadyCounteredSpells;
@end

@implementation AITPerfectCounter

-(id)init {
    if ((self = [super init])) {
        self.alreadyCounteredSpells = [NSMutableDictionary new];
    }
    return self;
}

-(BOOL)isCountered:(Spell*)spell {
    return ([self.alreadyCounteredSpells objectForKey:spell.spellId] != nil);
}

-(Spell*)counterspell:(Spell*)spell {
    NSString * counterType = self.counters[spell.type];
    if (!counterType) return nil;
    return [Spell fromType:counterType];
}

-(AIAction*)suggestedAction:(AIGameState *)game {
    
    AIAction * action;
    
    if (game.isCooldown) return nil;
    
    // no, they should be SORTED by distance
    NSArray * uncounteredSpells = [game.opponentSpells filter:^BOOL(Spell * spell) {
        return ![self isCountered:spell];
    }];
    
    if (!uncounteredSpells.count) return nil;
    
    NSArray * closest = [game sortSpellsByDistance:uncounteredSpells];

    Spell * spell = closest[0];
    Spell * counter = [self counterspell:spell];
    if (counter) {
        action = [AIAction spell:counter priority:2];
        self.alreadyCounteredSpells[spell.spellId] = @YES;
    }
    
    return action;
}

+(id)counters:(NSDictionary *)counters {
    AITPerfectCounter * tactic = [AITPerfectCounter new];
    tactic.counters = counters;
    return tactic;
}
@end
