//
//  Spell.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Spell.h"

@implementation Spell

-(id)init {
    if ((self = [super init])) {
        self.type = NSStringFromClass([self class]);
        self.created = CACurrentMediaTime();
        self.damage = 1; // default value
        self.speed = 30;
        self.strength = 1; // destroyed is read from this
        self.mana = 1;
    }
    return self;
}

// then you also have to update the sprites BASED on this.
// maybe update should be called on the sprites?
-(void)update:(NSTimeInterval)dt {
    self.position = [self move:dt];
}

-(float)move:(NSTimeInterval)dt {
    return self.position + self.direction * self.speed * dt;
}

-(void)reflectFromSpell:(Spell*)spell {
    self.direction *= -1;
//    self.position = spell.position + (1+(spell.size+self.size)/2)*self.direction;
//    self.position = spell.position + (1+(spell.size+self.size)/2)*self.direction;
}

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"speed", @"position", @"created", @"type", @"direction", @"createdTick", @"strength"]];
}

-(void)setPositionFromPlayer:(Player*)player {
    self.direction = 1;
    
    if (!player.isFirstPlayer)
        self.direction = -1;
    
    // makes it so it isn't RIGHT ON the player
    self.position = player.position + self.direction;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ pos=%i", super.description, (int)self.position];
}

-(BOOL)isType:(Class)class {
    NSString * className = NSStringFromClass(class);
    return [self.type isEqualToString:className];
}

-(SpellInteraction*)interactSpell:(Spell*)spell {
    // interact spell should contain the HALF of the spell that matters
    // so if fireball destroys earthwall and continues
        // fireball interact: nothing
        // earthwall interact: destroys
    NSLog(@" !!! Override interactSpell in subclass %@", NSStringFromClass([self class]));
    return [SpellInteraction nothing];
}

-(SpellInteraction*)interactPlayer:(Player*)player {
    player.health -= self.damage;
    [player setState:PlayerStateHit animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HealthManaUpdate" object:nil];
    return nil;
}

-(BOOL)hitsPlayer:(Player*)player duringInterval:(NSTimeInterval)dt {
    
    // ignore the time interval. Wait until the spell is ALL THE WAY past the player
    // unlike spells hits, we want to give the player the benefit of the doubt
    // plus, can't reflect :)
    
    if (player.isFirstPlayer) {
        return self.position <= player.position;
    }
    else {
        return self.position >= player.position;
    }
}


// NEW HITTING ALGORITHM
// if the positions will cross during this tick, given their current directions
-(BOOL)hitsSpell:(Spell *)spell duringInterval:(NSTimeInterval)dt {
    // return if it WILL cross positions during this
    float spellStart = spell.position;
    float spellEnd = [spell move:dt];
    
    float selfStart = self.position;
    float selfEnd = [self move:dt];
    
    
    if (spellStart < selfStart) {
        return (spellEnd >= selfEnd);
    }
    
    else {
        return (spellEnd <= selfEnd);
    }
}

+(Spell*)fromType:(NSString*)type {
    return [NSClassFromString(type) new];
}

-(BOOL)isActive {
    return self.strength > 0;
}

-(BOOL)destroyed {
    return self.strength == 0;
}

-(void)setDestroyed:(BOOL)value {
    if (value) self.strength = 0;
    else if (self.strength == 0) self.strength = 1;
}


@end
