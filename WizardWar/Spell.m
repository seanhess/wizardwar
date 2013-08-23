//
//  Spell.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Spell.h"
#import "Tick.h"
#import "PEBasicDamage.h"
#import "NSArray+Functional.h"
#import "SpellEffectService.h"
#import "SpellInfo.h"

@interface Spell ()
@end

@implementation Spell

-(id)init {
    NSLog(@"Call initWithInfo instead");
    abort();
}

-(id)initWithInfo:(SpellInfo *)info {
    if ((self = [super init])) {
        self.type = info.type;
        self.damage = info.damage;
        self.speed = info.speed;
        self.speedY = info.speedY;
        self.strength = info.strength;
        self.startOffsetPosition = info.startOffsetPosition;
        self.targetSelf = info.targetSelf;
        self.heavy = info.heavy;
        self.castDelay = info.castDelay;
        self.name = info.name;
        self.isWall = info.isWall;
        self.altitude = info.altitude;
        self.height = info.height;
        
        self.status = SpellStatusPrepare;
        self.spellId = [Spell generateSpellId];
    }
    return self;
}

-(NSString*)name {
    if (!_name) return self.type;
    return _name;
}

-(void)initCaster:(Wizard*)player tick:(NSInteger)tick {
    self.creator = player;
    self.createdTick = tick;
    [self setPositionFromPlayer:player];
}

-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    self.position = [self move:interval];
    self.altitude = self.altitude + self.speedY*interval;
    return NO;
}

-(float)move:(NSTimeInterval)dt {
    return self.position + [self moveDx:dt];
}

-(float)moveDx:(NSTimeInterval)dt {
    return self.direction * self.speed * dt;    
}

-(float)moveFromReferencePosition:(NSTimeInterval)dt {
    return self.referencePosition + self.direction * self.speed * dt;
}

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"speed", @"referencePosition", @"type", @"direction", @"createdTick", @"strength", @"status", @"updatedTick"]];
}

-(void)setPositionFromPlayer:(Wizard*)player {
    self.direction = player.direction;
    // makes it so it isn't RIGHT ON the player
    self.referencePosition = player.position + self.direction * self.startOffsetPosition;
    self.position = self.referencePosition;
    
    if (self.heavy)
        self.altitude = 0;
    else if (self.altitude == 0) // you can set the altitude yo-self
        self.altitude = player.altitude;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<%@ pos=%i dir=%i status=%i>", self.type, (int)self.position, self.direction, self.status];
}

- (CGFloat)topY {
    return self.altitude + self.height/2.0;
}

- (CGFloat)bottomY {
    return self.altitude - self.height/2.0;
}

-(BOOL)hitsPlayer:(Wizard*)player duringInterval:(NSTimeInterval)dt {
    
    if (player.altitude < self.bottomY || self.topY < player.altitude) return NO;

    // TEST: does it start on one side of the player and end up on the other?
    
    float spellStart = self.position;
    float spellEnd = [self move:dt];
    
    if (spellStart < player.position) {
        return spellEnd >= player.position;
    }
    else {
        return spellEnd <= player.position;
    }
}

-(NSInteger)roundedAltitude:(CGFloat)altitude {
    return floorf(altitude);
}


// NEW HITTING ALGORITHM
// if the positions will cross during this tick, given their current directions
// I should check whether they DID cross, just barely.
// not whether they are about to.
-(BOOL)didHitSpell:(Spell *)spell duringInterval:(NSTimeInterval)dt {
    
//    NSLog(@"DID HIT SPELL? %@ %.2f %.2f ::: %@ %.2f %.2f", self.name, self.bottomY, self.topY, spell.name, spell.bottomY, spell.topY);
    if (self.topY <= spell.bottomY || self.bottomY >= spell.topY) return NO;
//    if ([self roundedAltitude:self.altitude] != [self roundedAltitude:spell.altitude]) return NO;

    // return if it WILL cross positions during this time interval
    float spellStart = [spell move:-dt];
    float spellEnd = spell.position;
    
    float selfStart = [self move:-dt];
    float selfEnd = self.position;
    
    if (spellStart < selfStart) {
        return (spellEnd >= selfEnd);
    }
    
    else if (spellStart > selfStart) {
        return (spellEnd <= selfEnd);
    }
    
    else {
        // If they STARTED touching, we counted the hit last time
        // unless they are STILL touching, in which case they did hit (again)
        return (spellEnd == selfEnd);
    }
}

+(NSString*)generateSpellId {
    return [NSString stringWithFormat:@"%i", arc4random()];
}

+(Spell*)fromType:(NSString*)type {
    // it MIGHT have a class
    SpellInfo * info = [SpellEffectService.shared infoForType:type];
    if (!info) return nil;
    Spell * spell = [[info.class alloc] initWithInfo:info];
    return spell;
}

-(BOOL)isType:(NSString*)type {
    return [self.type isEqualToString:type];
}

-(BOOL)isAnyType:(NSArray*)types {
    id match = [types find:^BOOL(NSString* type) {
        return [self isType:type];
    }];
    
    return (match != nil);
}

@end
