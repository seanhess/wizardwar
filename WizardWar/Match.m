//
//  Match.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Match.h"
#import "Spell.h"
#import "Player.h"
#import <Firebase/Firebase.h>

@interface Match ()
@property (nonatomic, strong) Firebase * matchNode;
@property (nonatomic, strong) Firebase * spellsNode;
@property (nonatomic, strong) Firebase * playersNode;
@end

// don't really know which player you are until there are 2 players
// then you can go off their name.
// Alphabetical order baby :)

@implementation Match
-(id)initWithId:(NSString *)id currentPlayer:(Player *)player {
    if ((self = [super init])) {
        self.players = [NSMutableArray array];
        self.spells = [NSMutableArray array];
        
        self.started = NO;
        
        // Firebase
        self.matchNode = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wizardwar.firebaseio.com/match/%@", id]];
        self.spellsNode = [self.matchNode childByAppendingPath:@"spells"];
        self.playersNode = [self.matchNode childByAppendingPath:@"players"];
        
        
        // PLAYERS
        [self.playersNode observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
            Player * player = [Player new];
            [player setValuesForKeysWithDictionary:snapshot.value];
            [self.players addObject:player];
            
            if ([player.name isEqualToString:self.currentPlayer.name]) {
                self.currentPlayer = player;
            }
            
            [self checkStart];
        }];
        
        self.currentPlayer = player;
        
        // FAKE SECOND PLAYER
        Player * fakeSecondPlayer = [Player new];
        fakeSecondPlayer.name = @"FakeSecondPlayer";
        [self joinPlayer:fakeSecondPlayer];
        
        [self joinPlayer:self.currentPlayer];
        
        
        
        // SPELLS
        [self.spellsNode observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
            Spell * spell = [Spell new];
            [spell setValuesForKeysWithDictionary:snapshot.value];
            [self.spells addObject:spell];
            [self.delegate didAddSpell:spell];
        }];
    }
    return self;
}


/// UPDATES

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



// STARTING

-(void)checkStart {
    NSLog(@"check Start %@", self.players);
    if (self.players.count >= 2) {
        [self start];
    }
}

-(void)start {
    self.started = YES;
    
    // sort alphabetically
    [self.players sortUsingComparator:^NSComparisonResult(Player * p1, Player *p2) {
        return [p1.name compare:p2.name];
    }];
    
    [self.players[0] setPosition:UNITS_MIN];
    [self.players[1] setPosition:UNITS_MAX];
    NSLog(@"START %@", self.players);
    [self.delegate matchStarted];
}


/// ADDING STUFF

-(void)joinPlayer:(Player*)player {
    // [self.players addObject:player];
    Firebase * node = [self.playersNode childByAppendingPath:player.name];
    [node onDisconnectRemoveValue];
    [node setValue:[player toObject]];
}

-(void)addSpell:(Spell*)spell {
//    [self.spells addObject:spell];
    Firebase * spellNode = [self.spellsNode childByAutoId];
//    [spellNode onDisconnectRemoveValue];
    [spellNode setValue:[spell toObject]];
    [spellNode onDisconnectRemoveValue];
    spell.firebaseName = spellNode.name;
}

-(void)removeSpell:(Spell*)spell {
    NSLog(@"REMOVE SPELL %@", spell.firebaseName);
    Firebase * spellNode = [self.spellsNode childByAppendingPath:spell.firebaseName];
    [self.spells removeObject:spell];
    [self.delegate didRemoveSpell:spell];
    [spellNode removeValue];
}

@end
