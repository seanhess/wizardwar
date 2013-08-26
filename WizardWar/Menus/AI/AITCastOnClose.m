//
//  AITCastOnClose.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITCastOnClose.h"
#import "NSArray+Functional.h"

@implementation AITCastOnClose

-(AIAction *)suggestedAction:(AIGameState *)game {
    
    // He needs to be able to say to wait.
    // If something is too close. 
    if (game.isCooldown) return nil;
    
    AIAction * action;
    
    // Whichever spell is closest, adjust to match that
    NSArray * incoming = [game.incomingSpells filter:^BOOL(Spell* spell) {
        return ([spell hitsAltitude:game.wizard.altitude] || spell.position == game.wizard.position);
    }];
    if (!incoming.count) return nil;
    
    NSArray * close = [game sortSpellsByDistance:incoming];
    Spell * closest = close[0];
    
    // Mark that particular spell as cleared?
    
    if ([closest distance:game.wizard] <= self.distance) {
        if (closest.altitude >= 1.0)
            action = [AIAction spell:[Spell fromType:self.highSpell] priority:15];
        else
            action = [AIAction spell:[Spell fromType:self.lowSpell] priority:15];
    }
    
    return action;
}

+(id)distance:(float)distance highSpell:(NSString*)high lowSpell:(NSString*)low {
    AITCastOnClose * t = [AITCastOnClose new];
    t.distance = distance;
    t.highSpell = high;
    t.lowSpell = low;
    return t;
}

@end
