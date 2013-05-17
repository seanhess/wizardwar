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
    }
    return self;
}

// then you also have to update the sprites BASED on this.
// maybe update should be called on the sprites?
-(void)update:(NSTimeInterval)dt {
    self.position += self.speed * dt;
    [self.delegate didUpdateForRender];
}

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"speed", @"size", @"position", @"created", @"type"]];
}

-(void)setPositionFromPlayer:(Player*)player {
    self.position = player.position;
    if (!player.isFirstPlayer) {
        self.speed *= -1;
    }
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ - %f", super.description, self.type, self.position];
}

-(BOOL)isType:(Class)class {
    return [self.type isEqualToString:NSStringFromClass(class)];
}

-(SpellInteraction*)interactSpell:(Spell*)spell {
    // interact spell should contain the HALF of the spell that matters
    // so if fireball destroys earthwall and continues
        // fireball interact: nothing
        // earthwall interact: destroys
    NSLog(@" !!! Override interactSpell in subclass %@", NSStringFromClass([self class]));
    return [SpellInteraction nothing];
}

-(SpellInteraction*)interactPlayer:(Spell*)spell {
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

@end
