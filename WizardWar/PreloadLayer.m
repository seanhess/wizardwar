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

+(void)loadSpells {
    NSLog(@"------ PRELOAD -------");
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SpellSprite loadSprites];
        [WizardSprite loadSprites];
        
        PreloadLayer * layer = [PreloadLayer new];
        [WizardDirector runLayer:layer];
        [layer load];
        [WizardDirector stop];
//    });
}

+(void)loadWizards {
    
}

-(void)load {
    
    NSArray * spellClasses = [Combos allSpellClasses];
    
    for (Class SpellType in spellClasses) {
        Spell * spell = [SpellType new];
        NSLog(@"PRELOAD %@", spell.type);
        SpellSprite * sprite = [[SpellSprite alloc] initWithSpell:spell units:nil];
        [self addChild:sprite];
    }
    
    Wizard * wizard = [Wizard new];
    wizard.name = @"preload bot";
    wizard.state = WizardStatusReady;
    wizard.wizardType = WIZARD_TYPE_ONE;
    
    // set 1: attack, celebrate, prepare
    // set 2: dead, damage, sleep
    
    WizardSprite * wizardSprite = [[WizardSprite alloc] initWithWizard:wizard units:nil match:nil isCurrentWizard:YES];
    [self addChild:wizardSprite];
    
    wizard.state = WizardStatusHit;
}

@end
