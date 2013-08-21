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

@interface Spell ()
@end

@implementation Spell

-(id)init {
    if ((self = [super init])) {
        self.type = NSStringFromClass([self class]);
        self.damage = 1; // default value
        self.speed = 30; // 30 units per second
        self.strength = 1; // destroyed is read from this
        self.startOffsetPosition = 1;
        self.status = SpellStatusPrepare;
        self.altitude = 0;
        self.targetSelf = NO;
        self.heavy = YES;
        self.castDelay = 0.8;
        
        self.spellId = [Spell generateSpellId];
    }
    return self;
}

+(NSString*)type {
    return NSStringFromClass(self);
}

-(NSString*)name {
    if (!_name)
        return self.type;
    return _name;
}

-(void)initCaster:(Wizard*)player tick:(NSInteger)tick {
    self.creator = player;
    self.createdTick = tick;
    [self setPositionFromPlayer:player];
}

-(SpellInteraction*)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    self.position = [self move:interval];
    return nil;
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
    else
        self.altitude = player.altitude;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<%@ pos=%i dir=%i status=%i>", self.type, (int)self.position, self.direction, self.status];
}

-(BOOL)isType:(Class)class {
    NSString * className = NSStringFromClass(class);
    return [self.type isEqualToString:className];
}

-(SpellInteraction*)interactSpell:(Spell*)spell currentTick:(NSInteger)currentTick {
    // interact spell should contain the HALF of the spell that matters
    // so if fireball destroys earthwall and continues
        // fireball interact: nothing
        // earthwall interact: destroys
    NSLog(@" !!! Override interactSpell in subclass %@", NSStringFromClass([self class]));
    return [SpellInteraction nothing];
}



-(BOOL)hitsPlayer:(Wizard*)player duringInterval:(NSTimeInterval)dt {
    
    if (self.altitude != player.altitude) return NO;

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


// NEW HITTING ALGORITHM
// if the positions will cross during this tick, given their current directions
// I should check whether they DID cross, just barely.
// not whether they are about to.
-(BOOL)didHitSpell:(Spell *)spell duringInterval:(NSTimeInterval)dt {
    
    if (self.altitude != spell.altitude) return NO;

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
    Class SpellClass = [self classFromType:type];
    return [SpellClass new];
}

+(Class)classFromType:(NSString*)type {
    return NSClassFromString(type);
}


@end
