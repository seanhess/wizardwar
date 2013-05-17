//
//  Match.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Match.h"
#import "Spell.h"
#import <Firebase/Firebase.h>

@interface Match ()
@property (nonatomic, strong) Firebase * matchNode;
@property (nonatomic, strong) Firebase * spellsNode;
@property (nonatomic, strong) Firebase * playersNode;
@end

@implementation Match
-(id)initWithId:(NSString *)id {
    if ((self = [super init])) {
        self.players = [NSMutableArray array];
        self.spells = [NSMutableArray array];
        
        // Firebase
        self.matchNode = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wizardwar.firebaseio.com/match/%@", id]];
        self.spellsNode = [self.matchNode childByAppendingPath:@"spells"];
    }
    return self;
}

-(void)update:(NSTimeInterval)dt {
    [self.spells enumerateObjectsUsingBlock:^(Spell* spell, NSUInteger idx, BOOL *stop) {
        [spell update:dt];
    }];
    
    [self checkHitPlayers];
}

-(void)checkHitPlayers {
    [self.spells enumerateObjectsUsingBlock:^(Spell* spell, NSUInteger idx, BOOL *stop) {
        // spells are center anchored, so just check the position, not the width?
        // TODO add spell size to the equation
        // check to see if the spell hits ME, not all players
        // or check to see how my spells hit?
        if (spell.position >= 100 || spell.position < 0)
            [self removeSpell:spell];
    }];
}

-(void)addSpell:(Spell*)spell {
    [self.spells addObject:spell];
    Firebase * spellNode = [self.spellsNode childByAutoId];
//    [spellNode onDisconnectRemoveValue];
    [spellNode setValue:[spell toObject]];
    spell.firebaseName = spellNode.name;
}

-(void)removeSpell:(Spell*)spell {
    NSLog(@"REMOVE SPELL %@", spell.firebaseName);
    Firebase * spellNode = [self.spellsNode childByAppendingPath:spell.firebaseName];
    [spellNode removeValue];
    [self.spells removeObject:spell];
    [self.delegate didRemoveSpell:spell];
}

@end
