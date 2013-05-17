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
        self.size = 10; // don't make this too small or they could miss between frames!
        self.damage = 1; // default value
    }
    return self;
}

// then you also have to update the sprites BASED on this.
// maybe update should be called on the sprites?
-(void)update:(NSTimeInterval)dt {
    self.position += self.direction * self.speed * dt;
    [self.delegate didUpdateForRender];
}

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"speed", @"size", @"position", @"created", @"type", @"direction"]];
}

-(void)setPositionFromPlayer:(Player*)player {
    self.direction = 1;
    
    if (!player.isFirstPlayer)
        self.direction = -1;
    
    // makes it so it isn't RIGHT ON the player
    self.position = player.position + self.size*self.direction;
    
    NSLog(@"CHECK %@", self);
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ - %f", super.description, self.type, self.position];
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
    // TODO figure this out / model it
    return nil;
}

-(BOOL)hitsPlayer:(Player*)player {
    if (player.isFirstPlayer) {
        return self.position <= player.position;
    }
    else {
        return self.position >= player.position;
    }
}

// in units
-(CGFloat)rightEdge {
    return self.position+self.size/2;
}

-(CGFloat)leftEdge {
    return self.position-self.size/2;
}

-(BOOL)hitsSpell:(Spell *)spell {
    return ((spell.rightEdge >= self.leftEdge) || (spell.leftEdge <= self.rightEdge));
}

+(Spell*)fromType:(NSString*)type {
    return [NSClassFromString(type) new];
}

@end
