//
//  PreloadLayer.m
//  WizardWar
//
//  Created by Sean Hess on 8/7/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "PreloadLayer.h"
#import "SpellSprite.h"
#import "SpellMonster.h"
#import "WizardDirector.h"
#import "WizardSprite.h"
#import "SpellVine.h"
#import "Combos.h"

@implementation PreloadLayer

+(void)loadSprites {
    NSLog(@"------ PRELOAD -------");
    [SpellSprite loadSprites];
    [WizardSprite loadSprites];
    
    PreloadLayer * layer = [PreloadLayer new];
    [WizardDirector runLayer:layer];
    [layer load];
    [WizardDirector stop];
}

-(void)load {
    
    NSArray * spellClasses = [Combos allSpellClasses];
    
    for (Class SpellType in spellClasses) {
        Spell * spell = [SpellType new];
        NSLog(@"PRELOAD %@", spell.type);
        SpellSprite * sprite = [[SpellSprite alloc] initWithSpell:spell units:nil];
        [self addChild:sprite];
    }
    

}

@end
