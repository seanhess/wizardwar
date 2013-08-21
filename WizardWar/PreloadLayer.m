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
#import "SpellsLayer.h"
#import "SpellEffectService.h"
#import "SpellInfo.h"

@implementation PreloadLayer

+(void)loadSpells {
    NSLog(@"------ PRELOAD -------");
        PreloadLayer * layer = [PreloadLayer new];
        [WizardDirector runLayer:layer];
        [layer load];
        [WizardDirector stop];
}

+(void)loadWizards {
    
}

-(void)load {
    
    self.position = ccp(-1000, -1000);
    
    NSArray * spellTypes = [SpellEffectService.shared allSpellTypes];
    
    SpellsLayer * spells = [SpellsLayer new];
    [self addChild:spells];
    
    for (SpellInfo* spellType in spellTypes) {
        Spell * spell = [Spell fromType:spellType.type];
        NSLog(@"PRELOAD %@", spell.type);
        SpellSprite * sprite = [[SpellSprite alloc] initWithSpell:spell units:nil];
        [spells addSpell:sprite];
    }
    
    Wizard * wizard = [Wizard new];
    wizard.name = @"preload bot";
    NSLog(@"PRELOAD wizard %i", WizardStatusReady);
    wizard.state = WizardStatusReady;
    wizard.wizardType = WIZARD_TYPE_ONE;
    
    WizardSprite * wizardSprite = [[WizardSprite alloc] initWithWizard:wizard units:nil match:nil isCurrentWizard:YES];
    [self addChild:wizardSprite];

    NSLog(@"PRELOAD wizard %i", WizardStatusHit);
    wizard.state = WizardStatusHit;
    NSLog(@"PRELOAD wizard %i", WizardStatusCast);
    wizard.state = WizardStatusCast;
}

@end
