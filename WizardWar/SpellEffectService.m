//
//  SpellEffectService.m
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//
#import "SpellEffectService.h"
#import "NSArray+Functional.h"

#import "SpellEarthwall.h"
#import "SpellMonster.h"
#import "SpellVine.h"
#import "SpellIcewall.h"
#import "SpellFirewall.h"
#import "SpellFist.h"
#import "SpellFailRainbow.h"

#import "PEApply.h"
#import "PEBasicDamage.h"
#import "PEHeal.h"
#import "PEHelmet.h"
#import "PEInvisible.h"
#import "PELevitate.h"
#import "PESleep.h"
#import "PEUndies.h"
#import "PENone.h"

#import "SpellEffect.h"

#import "SpellInfo.h"




@interface SpellEffectService ()
@property (nonatomic, strong) NSMapTable * spellEffectDefaults;
@property (nonatomic, strong) NSMapTable * spellInteractions;
@property (nonatomic, strong) NSMapTable * playerEffects;
@property (nonatomic, strong) NSMutableDictionary * spellsByType;
@property (nonatomic, strong) NSMapTable * spellsByClass;
@end

@implementation SpellEffectService

+ (SpellEffectService *)shared {
    static SpellEffectService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SpellEffectService alloc] init];
    });
    return instance;
}


-(id)init {
    self = [super init];
    if (self) {
        self.spellEffectDefaults = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        self.spellInteractions = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        self.playerEffects = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        
        self.spellsByClass = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        self.spellsByType = [NSMutableDictionary dictionary];
        
        [self createSpells];
        [self createSpellInteractions];
        
        NSLog(@"------ SpellEffectService: loaded -------");
    }
    return self;
}

-(SpellInfo*)infoForType:(NSString*)type {
    return [self.spellsByType objectForKey:type];
}


-(void)createSpells {
    SpellInfo * fireball = [SpellInfo type:Fireball];
    fireball.name = @"Fireball";
    fireball.heavy = NO;
    
    SpellInfo * hotdog = [SpellInfo type:Hotdog];
    hotdog.name = @"Hotdog";
    hotdog.heavy = NO;
    hotdog.damage = 0;
    
    SpellInfo * teddy = [SpellInfo type:Teddy];
    teddy.name = @"Teddy";
    teddy.heavy = NO;
    teddy.damage = 0;
    
    SpellInfo * undies = [SpellInfo type:Undies];
    undies.name = @"Wizard Undies";
    undies.heavy = NO;
    undies.damage = 0;
    
    SpellInfo * chicken = [SpellInfo type:Chicken];
    chicken.name = @"Summon Chicken";
    chicken.heavy = YES;
    chicken.damage = 3;
    
    SpellInfo * captain = [SpellInfo type:CaptainPlanet];
    captain.name = @"Captain Planet";
    captain.heavy = YES;
    captain.damage = 0;
    captain.speed = 18;
    
    SpellInfo * lightning = [SpellInfo type:Lightning];
    lightning.heavy = NO;
    lightning.name = @"Lightning Orb";
    
    SpellInfo * helmet = [SpellInfo type:Helmet];
    helmet.speed = 0;
    helmet.damage = 0;
    helmet.targetSelf = YES;
    helmet.name = @"Mighty Helmet";
    
    SpellInfo * bubble = [SpellInfo type:Bubble];
    bubble.name = @"Bubble";
    bubble.damage = 0;
    bubble.heavy = NO;
    bubble.speed = 20;
    
    SpellInfo * windblast = [SpellInfo type:Windblast];
    windblast.name = @"Wind Blast";
    windblast.speed = 60;
    windblast.damage = 0;
    windblast.heavy = NO;
    windblast.castDelay = 0.3;
    
    
    SpellInfo * invisibility = [SpellInfo type:Invisibility];
    invisibility.name = @"Invisibility";
    invisibility.speed = 0;
    invisibility.damage = 0;
    invisibility.targetSelf = YES;
    
    SpellInfo * heal = [SpellInfo type:Heal];
    heal.name = @"Heal";
    heal.speed = 0;
    heal.damage = 0;
    heal.targetSelf = YES;
    
    SpellInfo * levitate = [SpellInfo type:Levitate];
    levitate.name = @"Levitate";
    levitate.speed = 0;
    levitate.damage = 0;
    levitate.targetSelf = YES;
    
    SpellInfo * sleep = [SpellInfo type:Sleep];
    sleep.name = @"Sleep";
    sleep.damage = 0;
    sleep.heavy = NO;
    
    
    SpellInfo * firewall = [SpellInfo type:Firewall class:[SpellFirewall class]];
    SpellInfo * earthwall = [SpellInfo type:Earthwall class:[SpellEarthwall class]];
    SpellInfo * icewall = [SpellInfo type:Icewall class:[SpellIcewall class]];
    SpellInfo * monster = [SpellInfo type:Monster class:[SpellMonster class]];
    SpellInfo * vine = [SpellInfo type:Vine class:[SpellVine class]];
    SpellInfo * fist = [SpellInfo type:Fist class:[SpellFist class]];
    SpellInfo * rainbow = [SpellInfo type:Rainbow class:[SpellFailRainbow class]];
    
    self.allSpellTypes = @[
        lightning,
        firewall,
        invisibility,
        heal,
        fireball,
        earthwall,
        icewall,
        windblast,
        monster,
        bubble,
        vine,
        fist,
        helmet,
        levitate,
        sleep,
        captain,
        chicken,
        hotdog,
        rainbow,
        teddy,
        undies,
    ];
    
    [self.allSpellTypes forEach:^(SpellInfo*spell) {
        [self.spellsByType setObject:spell forKey:spell.type];
        [self.spellsByClass setObject:spell forKey:spell.class];
    }];
}

-(void)createSpellInteractions {
    
    [self spell:Hotdog effect:[SEDestroy new] spell:Monster effect:[SEStronger new]];
    [self spell:Teddy player:[PEHeal delay:0]];
    [self spell:Undies player:[PEUndies new]];
    [self spell:Chicken default:[SEDestroy new]];
    // Rainbow doesn't do anything
    // CaptainPlanet doesn't do anything    
    
    [self spell:Fireball effect:[SENone new] spell:Monster effect:[SEDestroy new]];
    [self spell:Fireball effect:[SEDestroy new] spell:Vine effect:[SEDestroy new]];
    
    [self spell:Windblast player:[PENone new]];
    [self spell:Windblast effect:[SENone new] spell:Fireball effect:[SEStronger new]];
    [self spell:Windblast effect:[SENone new] spell:Bubble effect:[SESpeed speedUp:35 slowDown:35]];
    [self spell:Windblast effect:[SENone new] spell:Monster effect:[SESpeed speedUp:30 slowDown:15]];
    
    [self spell:Bubble effect:[SENone new] spell:Fireball effect:[SECarry new]];
    [self spell:Bubble effect:[SENone new] spell:Sleep effect:[SECarry new]];
    [self spell:Bubble effect:[SENone new] spell:Firewall effect:[SECarry new]];
    
    [self spell:Lightning effect:[SEStronger new] spell:Fireball effect:[SEDestroy new]];

    [self spell:Icewall effect:[SEWeaker new] spell:Lightning effect:[SEDestroy new]];
    [self spell:Icewall effect:[SENone new] spell:Sleep effect:[SEDestroy new]];
    [self spell:Icewall effect:[SENone new] spell:Bubble effect:[SEReflect new]];
    [self spell:Icewall effect:[SENone new] spell:Windblast effect:[SEReflect new]];
    [self spell:Icewall effect:[SEDestroy new] spell:Fireball effect:[SEDestroy new]];    
    
    [self spell:Earthwall effect:[SEWeaker new] spell:Fireball effect:[SEDestroy new]];
    [self spell:Earthwall effect:[SEDestroy new] spell:Monster effect:[SESpeed setTo:5]];
    
    [self spell:Firewall effect:[SEWeaker new] spell:Monster effect:[SEDestroy new]];
    [self spell:Firewall effect:[SEWeaker new] spell:Vine effect:[SEDestroy new]];
    
    [self spell:Earthwall effect:[SEDestroyOlder new] spell:Earthwall effect:[SEDestroyOlder new]];
    [self spell:Earthwall effect:[SEDestroyOlder new] spell:Icewall effect:[SEDestroyOlder new]];
    [self spell:Earthwall effect:[SEDestroyOlder new] spell:Firewall effect:[SEDestroyOlder new]];
    [self spell:Icewall effect:[SEDestroyOlder new] spell:Icewall effect:[SEDestroyOlder new]];
    [self spell:Icewall effect:[SEDestroyOlder new] spell:Firewall effect:[SEDestroyOlder new]];
    [self spell:Firewall effect:[SEDestroyOlder new] spell:Firewall effect:[SEDestroyOlder new]];

    [self spell:Monster effect:[SENone new] spell:Lightning effect:[SEDestroy new]];
    [self spell:Monster effect:[SENone new] spell:Bubble effect:[SEDestroy new]];
    [self spell:Monster effect:[SENone new] spell:Icewall effect:[SEDestroy new]];
    [self spell:Monster effect:[SEDestroy new] spell:Monster effect:[SEDestroy new]];
    
    [self spell:Helmet player:[PEHelmet new]];
    [self spell:Helmet effect:[SEDestroy new] spell:Fist effect:[SEDestroy new]];
    
    [self spell:Sleep player:[PESleep new]];
    [self spell:Sleep effect:[SEDestroy new] spell:Monster effect:[SESleep new]];
    
    [self spell:Heal player:[PEHeal delay:EFFECT_HEAL_TIME]];
    
    [self spell:Levitate player:[PELevitate new]];
    [self spell:Invisibility player:[PEInvisible new]];
}

// the normal default spell interaction is nothing
-(void)spell:(NSString*)Spell default:(SpellEffect*)effect {
    [self.spellEffectDefaults setObject:effect forKey:Spell];
}


-(void)spell:(NSString*)SpellOne effect:(SpellEffect*)effectOne spell:(NSString*)SpellTwo effect:(SpellEffect*)effectTwo {
    SpellInteraction * interactionOne = [SpellInteraction new];
    interactionOne.spell = SpellOne;
    interactionOne.otherSpell = SpellTwo;
    interactionOne.effect = effectOne;
    [self addInteraction:interactionOne];
    
    SpellInteraction * interactionTwo = [SpellInteraction new];
    interactionTwo.spell = SpellTwo;
    interactionTwo.otherSpell = SpellOne;
    interactionTwo.effect = effectTwo;
    [self addInteraction:interactionTwo];
}

// Add the interaction to BOTH of the spells referenced. It does apply to both after all
-(void)addInteraction:(SpellInteraction*)interaction {
    NSMutableArray * interactions = [self interactionsForSpell:interaction.spell];
    [interactions addObject:interaction];
    
    NSMutableArray * interactions2 = [self interactionsForSpell:interaction.otherSpell];
    [interactions2 addObject:interaction];
}

-(NSMutableArray*)interactionsForSpell:(NSString*)Spell {
    NSMutableArray * interactions = [self.spellInteractions objectForKey:Spell];
    if (!interactions) {
        interactions = [NSMutableArray new];
        [self.spellInteractions setObject:interactions forKey:Spell];
    }
    return interactions;
}

// You don't have to add player effects.
-(void)spell:(NSString*)SpellOne player:(PlayerEffect*)effect {
    [self.playerEffects setObject:effect forKey:SpellOne];
}

// Select EITHER spell to pull the interactions for, because they are duplicated on both
-(NSArray*)interactionsForSpell:(NSString*)SpellOne andSpell:(NSString*)SpellTwo {
    
    NSMutableArray * interactions = [self interactionsForSpell:SpellOne];
    
    NSMutableArray * matchingInteractions = [interactions filter:^BOOL(SpellInteraction*interaction) {
        return ([interaction.spell isEqualToString:SpellOne] && [interaction.otherSpell isEqualToString:SpellTwo])
            || ([interaction.spell isEqualToString:SpellTwo] && [interaction.otherSpell isEqualToString:SpellOne]);
    }];
    
    // if a default is set for a given spell, that means that if EITHER spell is that one then it should return it, unless some are set.
    
    if (matchingInteractions.count == 0) {
        SpellEffect * defaultEffectOne = [self.spellEffectDefaults objectForKey:SpellOne];
        SpellEffect * defaultEffectTwo = [self.spellEffectDefaults objectForKey:SpellTwo];
        
        if (defaultEffectOne) {
            SpellInteraction * defaultInteractionOne = [SpellInteraction new];
            defaultInteractionOne.spell = SpellOne;
            defaultInteractionOne.otherSpell = SpellTwo;
            defaultInteractionOne.effect = defaultEffectOne;
            [matchingInteractions addObject:defaultInteractionOne];
        }
        
        if (defaultEffectTwo) {
            SpellInteraction * defaultInteractionTwo = [SpellInteraction new];
            defaultInteractionTwo.spell = SpellTwo;
            defaultInteractionTwo.otherSpell = SpellOne;
            defaultInteractionTwo.effect = defaultEffectTwo;
            [matchingInteractions addObject:defaultInteractionTwo];
        }
        
    }
    
    // Remove None Interactions
    return [matchingInteractions filter:^BOOL(SpellInteraction * interaction) {
        return ![interaction.effect isKindOfClass:[SENone class]];
    }];
}

-(PlayerEffect*)playerEffectForSpell:(NSString*)Spell {
    PlayerEffect * effect = [self.playerEffects objectForKey:Spell];
    if (!effect) {
        effect = [PEBasicDamage new];
    }
    return effect;
}

@end
