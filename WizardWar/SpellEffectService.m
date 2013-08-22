//
//  SpellEffectService.m
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//
#import "SpellEffectService.h"
#import "NSArray+Functional.h"
#import "ComboService.h"

#import "Elements.h"

#import "SpellMonster.h"
#import "SpellVine.h"
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
#import "PECthulhu.h"

#import "SpellEffect.h"

#import "SpellInfo.h"


#define SPELL_WALL_OFFSET_POSITION 15

@interface SpellEffectService ()
@property (nonatomic, strong) NSMapTable * spellEffectDefaults;
@property (nonatomic, strong) NSMapTable * spellInteractions;
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
    SpellInfo * hotdog = [SpellInfo type:Hotdog];
    hotdog.name = @"Hotdog";
    hotdog.heavy = NO;
    hotdog.damage = 0;
    hotdog.explanation = @"The Hotdog makes a good snack for any nearby monsters.";
    hotdog.combo = [Combo basic5:Water];
    
    SpellInfo * teddy = [SpellInfo type:Teddy];
    teddy.name = @"Teddy";
    teddy.heavy = NO;
    teddy.damage = 0;
    teddy.effect = [PEHeal delay:0];
    teddy.explanation = @"Teddy lets you show your love to your opponent.";
    teddy.combo = [Combo basic5:Heart];
    
    SpellInfo * undies = [SpellInfo type:Undies];
    undies.name = @"Wizard Undies";
    undies.heavy = NO;
    undies.damage = 0;
    undies.effect = [PEUndies new];
    undies.explanation = @"These stylish Wizard Undies will be the talk of the next council meeting. Useful for cancelling effects.";
    undies.combo = [Combo basic5:Fire];
    
    SpellInfo * chicken = [SpellInfo type:Chicken];
    chicken.name = @"Summon Chicken";
    chicken.heavy = YES;
    chicken.damage = 3;
    chicken.explanation = @"Summoning a chicken is more dangerous than it looks. The chicken is destroyed if it touches any other spell.";
    chicken.combo = [Combo basic5:Earth];
    
    SpellInfo * captain = [SpellInfo type:CaptainPlanet];
    captain.name = @"Captain Planet";
    captain.heavy = YES;
    captain.damage = 0;
    captain.speed = 18;
    captain.explanation = @"By your powers combined, I am CAPTAIN PLANET!";
    captain.combo = [Combo exact:@[@(Earth), @(Fire), @(Air), @(Water), @(Heart)]];
    
    SpellInfo * fireball = [SpellInfo type:Fireball];
    fireball.name = @"Fireball";
    fireball.heavy = NO;
    fireball.explanation = @"Fireball is good burning things. Far things.";
    fireball.combo = [Combo air:YES heart:YES water:0 earth:0 fire:YES];
    
    SpellInfo * lightning = [SpellInfo type:Lightning];
    lightning.heavy = NO;
    lightning.name = @"Lightning Orb";
    lightning.explanation = @"Lightning Orb will show up in your opponents face, and he'll be all, 'What the heck is shocking me?'";
    lightning.combo = [Combo air:YES heart:0 water:YES earth:YES fire:0];
    
    SpellInfo * helmet = [SpellInfo type:Helmet];
    helmet.speed = 0;
    helmet.damage = 0;
    helmet.targetSelf = YES;
    helmet.name = @"Mighty Helmet";
    helmet.effect = [PEHelmet new];
    helmet.explanation = @"The Mighty Helmet is stronk! It make you look awesome!";
    helmet.combo = [Combo air:NO heart:YES water:NO earth:YES fire:YES];
    
    SpellInfo * bubble = [SpellInfo type:Bubble];
    bubble.name = @"Bubble";
    bubble.damage = 0;
    bubble.heavy = NO;
    bubble.speed = 20;
    bubble.explanation = @"Bubble turns your enemies' attacks against them, and kids love them too.";
    bubble.combo = [Combo air:NO heart:YES water:YES earth:NO fire:YES];
    
    SpellInfo * windblast = [SpellInfo type:Windblast];
    windblast.name = @"Wind Blast";
    windblast.speed = 60;
    windblast.damage = 0;
    windblast.heavy = NO;
    windblast.castDelay = 0.3;
    windblast.effect = [PENone new];
    windblast.explanation = @"Nothing like a little Windblast to shake things up.";
    windblast.combo = [Combo air:YES heart:NO water:YES earth:NO fire:YES];
    
    SpellInfo * invisibility = [SpellInfo type:Invisibility];
    invisibility.name = @"Invisibility";
    invisibility.speed = 0;
    invisibility.damage = 0;
    invisibility.targetSelf = YES;
    invisibility.effect = [PEInvisible new];
    invisibility.explanation = @"Turns you invisible, making you immune to most attacks. Cancels when you cast another spell.";
    invisibility.combo = [Combo air:YES heart:YES water:YES earth:NO fire:YES];
    
    SpellInfo * heal = [SpellInfo type:Heal];
    heal.name = @"Heal";
    heal.speed = 0;
    heal.damage = 0;
    heal.targetSelf = YES;
    heal.effect = [PEHeal delay:EFFECT_HEAL_TIME];
    heal.explanation = @"Slowly heals one heart. Cancels if hit while healing or if you cast another spell.";
    heal.combo = [Combo air:YES heart:YES water:NO earth:YES fire:NO];
    
    SpellInfo * sleep = [SpellInfo type:Sleep];
    sleep.name = @"Sleep";
    sleep.damage = 0;
    sleep.heavy = NO;
    sleep.effect = [PESleep new];
    sleep.explanation = @"Sleep will give you a few seconds of breathing room. Spam this to really piss people off.";
    sleep.combo = [Combo air:YES heart:YES water:0 earth:YES fire:YES];
    
    SpellInfo * firewall = [SpellInfo type:Firewall];
    firewall.name = @"Wall of Fire";
    firewall.isWall = YES;
    firewall.speed = 0;
    firewall.damage = 1;
    firewall.strength = 3;
    firewall.startOffsetPosition = SPELL_WALL_OFFSET_POSITION;
    firewall.castDelay = 0.5;
    firewall.explanation = @"The Wall of Fire is good for burning things that are closer than fireball. Also lasts longer.";
    firewall.combo = [Combo air:YES heart:NO water:NO earth:YES fire:YES];
    
    SpellInfo * earthwall = [SpellInfo type:Earthwall];
    earthwall.name = @"Wall of Earth";
    earthwall.isWall = YES;
    earthwall.speed = 0;
    earthwall.damage = 0;
    earthwall.strength = 3;
    earthwall.startOffsetPosition = SPELL_WALL_OFFSET_POSITION;
    earthwall.castDelay = 0.5;
    earthwall.explanation = @"The Wall of Earth is sturdy. I think.";
    earthwall.combo = [Combo air:NO heart:NO water:YES earth:YES fire:YES];
        
    SpellInfo * icewall = [SpellInfo type:Icewall];
    icewall.name = @"Wall of Ice";
    icewall.isWall = YES;
    icewall.speed = 0;
    icewall.damage = 0;
    icewall.strength = 3;
    icewall.startOffsetPosition = SPELL_WALL_OFFSET_POSITION;
    icewall.castDelay = 0.5;
    icewall.explanation = @"The Wall of Ice is like other walls, but secretly better.";
    icewall.combo = [Combo air:0 heart:YES water:YES earth:YES fire:0];
    
    SpellInfo * monster = [SpellInfo type:Monster class:[SpellMonster class]];
    monster.name = @"Summon Ogre";
    monster.explanation = @"Summon an Ogre to do your dirty work for you. We'd have gone with a dire badger but he was helping someone else.";
    monster.combo = [Combo air:0 heart:YES water:YES earth:YES fire:YES];

    
    SpellInfo * vine = [SpellInfo type:Vine class:[SpellVine class]];
    vine.name = @"Summon Vine";
    vine.explanation = @"The Vine is sneaky, dirty, and very, very, angry.";
    vine.combo = [Combo air:YES heart:0 water:YES earth:YES fire:YES];
    vine.castDelay = 2.0;
    vine.speed = 0;
    vine.startOffsetPosition = 85;
    
    SpellInfo * fist = [SpellInfo type:Fist];
    fist.name = @"Fist of Grom";
    fist.explanation = @"Grom will smite thy opponents from the heavens.";
    fist.combo = [Combo air:YES heart:YES water:YES earth:YES fire:0];
    fist.speed = 0;
    fist.strength = 1;
    fist.castDelay = 3.0;
    fist.altitude = 2.0;
    fist.speedY = -(fist.altitude)/(3.0);
    fist.startOffsetPosition = 100.0;
    fist.heavy = NO;
    
    SpellInfo * rainbow = [SpellInfo type:Rainbow class:[SpellFailRainbow class]];
    rainbow.name = @"Double Rainbow";
    rainbow.explanation = @"No one really knows what the Double Rainbow does.";
    rainbow.combo = [Combo basic5:Air];
    rainbow.speed = 0;
    rainbow.startOffsetPosition = 50;
    rainbow.damage = 0;
    
    SpellInfo * levitate = [SpellInfo type:Levitate];
    levitate.name = @"Levitate";
    levitate.speed = 0;
    levitate.damage = 0;
    levitate.targetSelf = YES;
    levitate.effect = [PELevitate new];
    levitate.explanation = @"Levitate gives you a height advantage, making most attacks miss.";
    levitate.combo = [Combo air:YES heart:YES water:YES earth:NO fire:NO];
    
    
    
    // I could give him a speed, he doesn't react with anything, and he kills you
    // it's all in the animation. 
    SpellInfo * cthulhu = [SpellInfo type:Cthulhu];
    cthulhu.name = @"Gate to R'lyeh";
    cthulhu.explanation = @"Some things are better left sealed. The Great Cthulhu appears and destruction follows in his wake.";
    cthulhu.combo = [Combo segments:[ComboSegments all]];
    cthulhu.speed = 0;
    cthulhu.startOffsetPosition = 0;
    cthulhu.damage = 666;
    cthulhu.castDelay = 4.0;
    cthulhu.strength = 666;
    cthulhu.altitude = 3.0;
    cthulhu.speedY = -1.0;
    cthulhu.effect = [PECthulhu new];
    cthulhu.heavy = NO;
    
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
        cthulhu,
    ];
    
    [self.allSpellTypes forEach:^(SpellInfo*spell) {
        [self.spellsByType setObject:spell forKey:spell.type];
        [self.spellsByClass setObject:spell forKey:spell.class];
        [ComboService.shared addCombo:spell.combo type:spell.type];
    }];

}

-(void)createSpellInteractions {
    
    [self spell:Hotdog effect:[SEDestroy new] spell:Monster effect:[SEStronger new]];
    
    [self spell:Chicken default:[SEDestroy new]];
    // Rainbow doesn't do anything
    // CaptainPlanet doesn't do anything
    
    [self spell:Fireball effect:[SENone new] spell:Monster effect:[SEDestroy new]];
    [self spell:Fireball effect:[SEDestroy new] spell:Vine effect:[SEDestroy new]];
    

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
    

    [self spell:Helmet effect:[SEDestroy new] spell:Fist effect:[SEDestroy new]];
    

    [self spell:Sleep effect:[SEDestroy new] spell:Monster effect:[SESleep new]];
    
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
//    NSLog(@"Add Interaction to %@ %@ %@", interaction.spell, interaction.otherSpell, interaction);
    NSMutableArray * interactions = [self interactionsForSpell:interaction.spell];
    [interactions addObject:interaction];
    
    NSMutableArray * interactions2 = [self interactionsForSpell:interaction.otherSpell];
    if (interactions2 != interactions)
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

-(PlayerEffect*)playerEffectForSpell:(NSString*)type {
    SpellInfo * info = [self infoForType:type];
    return info.effect;
}

@end
