//
//  SpellEffectService.m
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//
#import "SpellEffectService.h"

#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellVine.h"
#import "SpellWindblast.h"
#import "SpellIcewall.h"
#import "SpellInvisibility.h"
#import "SpellFirewall.h"
#import "SpellFist.h"
#import "SpellHelmet.h"
#import "SpellHeal.h"
#import "SpellLevitate.h"
#import "SpellSleep.h"
#import "SpellLightningOrb.h"

#import "SpellFailUndies.h"
#import "SpellFailTeddy.h"
#import "SpellFailRainbow.h"
#import "SpellFailChicken.h"
#import "SpellFailHotdog.h"

#import "SpellCheeseCaptainPlanet.h"
#import "EffectTeddyHeal.h"
#import "EffectApply.h"
#import "EffectBasicDamage.h"
#import "EffectHeal.h"
#import "EffectHelmet.h"
#import "EffectInvisible.h"
#import "EffectLevitate.h"
#import "EffectSleep.h"
#import "EffectUndies.h"

#import "SpellEffect.h"


#define Hotdog [SpellFailHotdog class]
#define Teddy [SpellFailTeddy class]
#define Undies [SpellFailUndies class]
#define Chicken [SpellFailChicken class]
#define Rainbow [SpellFailRainbow class]
#define Fireball [SpellFireball class]
#define Lightning [SpellLightningOrb class]
#define Fist [SpellFist class]
#define Helmet [SpellHelmet class]
#define Earthwall [SpellEarthwall class]
#define Firewall [SpellFirewall class]
#define Bubble [SpellBubble class]
#define Icewall [SpellIcewall class]
#define Monster [SpellMonster class]
#define Vine [SpellVine class]
#define Windblast [SpellWindblast class]
#define Invisibility [SpellInvisibility class]
#define Heal [SpellHeal class]
#define Levitate [SpellLevitate class]
#define Sleep [SpellSleep class]
#define CaptainPlanet [SpellCheeseCaptainPlanet class]


@interface PlayerEffect : Effect
@end

@implementation PlayerEffect
@end




@interface PEHeal : PlayerEffect
+(id)delay:(NSTimeInterval)delay;
@end

@interface PELevitate : PlayerEffect
@end

@interface SpellInteraction2 : NSObject
@property (nonatomic, strong) Class spell;
@property (nonatomic, strong) Class otherSpell;
@property (nonatomic, strong) SpellEffect* effect;
@end




@interface SpellEffectService ()
@property (nonatomic, strong) NSMutableDictionary * effects;
@property (nonatomic, strong) NSMutableDictionary * interactions;
@property (nonatomic, strong) NSMapTable * spellEffectDefaults;
@property (nonatomic, strong) NSMapTable * spellInteractions;
@property (nonatomic, strong) NSMapTable * playerEffects;
@end

@implementation SpellEffectService

-(id)init {
    self = [super init];
    if (self) {
        self.spellEffectDefaults = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        self.spellInteractions = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        self.playerEffects = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        
        [self createSpellInteractions];
    }
    return self;
}


-(void)createSpellInteractions {
    [self spell:Hotdog effect:[SEDestroy new] spell:Monster effect:[SEStronger new]];
    [self spell:Teddy player:[PEHeal delay:0]];
    [self spell:Undies player:[EffectUndies new]];
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
    
    [self spell:Lightning effect:[SENone new] spell:Fireball effect:[SEDestroy new]];

    [self spell:Icewall effect:[SEWeaker new] spell:Lightning effect:[SEDestroy new]];
    [self spell:Icewall effect:[SENone new] spell:Sleep effect:[SEDestroy new]];
    [self spell:Icewall effect:[SENone new] spell:Bubble effect:[SEReflect new]];
    [self spell:Icewall effect:[SENone new] spell:Windblast effect:[SEReflect new]];
    [self spell:Icewall effect:[SEDestroy new] spell:Fireball effect:[SEDestroy new]];    
    
    [self spell:Earthwall effect:[SEWeaker new] spell:Fireball effect:[SEDestroy new]];
    [self spell:Earthwall effect:[SEDestroy new] spell:Monster effect:[SESpeed setTo:5]];
    
    [self spell:Firewall effect:[SEWeaker new] spell:Monster effect:[SEDestroy new]];
    [self spell:Firewall effect:[SEWeaker new] spell:Vine effect:[SEDestroy new]];
    [self spell:Firewall effect:[SEDestroy new] spell:Earthwall effect:[SEDestroy new]];

    [self spell:Monster effect:[SENone new] spell:Lightning effect:[SEDestroy new]];
    [self spell:Monster effect:[SENone new] spell:Bubble effect:[SEDestroy new]];
    [self spell:Monster effect:[SENone new] spell:Icewall effect:[SEDestroy new]];
    [self spell:Monster effect:[SEDestroy new] spell:Monster effect:[SEDestroy new]];
    
    [self spell:Helmet player:[EffectHelmet new]];
    [self spell:Helmet effect:[SEDestroy new] spell:Fist effect:[SEDestroy new]];
    
    [self spell:Sleep player:[EffectSleep new]];
    [self spell:Sleep effect:[SEDestroy new] spell:Monster effect:[SESleep new]];
    
    [self spell:Heal player:[PEHeal delay:3.0]];
    
    [self spell:Levitate player:[PELevitate new]];
}

// the normal default spell interaction is nothing
-(void)spell:(Class)Spell default:(SpellEffect*)effect {
    [self.spellEffectDefaults setObject:effect forKey:Spell];
}


-(void)spell:(Class)SpellOne effect:(SpellEffect*)effectOne spell:(Class)SpellTwo effect:(SpellEffect*)effectTwo {
    SpellInteraction2 * interactionOne = [SpellInteraction2 new];
    interactionOne.spell = SpellOne;
    interactionOne.otherSpell = SpellTwo;
    interactionOne.effect = effectOne;
    [self addInteraction:interactionOne];
    
    SpellInteraction2 * interactionTwo = [SpellInteraction2 new];
    interactionTwo.spell = SpellTwo;
    interactionTwo.otherSpell = SpellOne;
    interactionTwo.effect = effectTwo;
    [self addInteraction:interactionTwo];
}

-(void)addInteraction:(SpellInteraction2*)interaction {
    NSMutableArray * interactions = [self interactionsForSpell:interaction.spell];
    [interactions addObject:interaction];
}

-(NSMutableArray*)interactionsForSpell:(Class)Spell {
    NSMutableArray * interactions = [self.spellInteractions objectForKey:Spell];
    if (!interactions) {
        interactions = [NSMutableArray new];
        [self.spellInteractions setObject:interactions forKey:Spell];
    }
    return interactions;
}

// You don't have to add player effects.
-(void)spell:(Class)SpellOne player:(Effect*)effect {
    [self.playerEffects setObject:effect forKey:SpellOne];
}

-(NSArray*)interactionsForSpell:(Class)SpellOne andSpell:(Class)SpellTwo {
    
    // returns all effects. The order doesn't matter!
    
    // each one can modify both spells? Or just one of them?
    // it can only modify one of them, I think.
    // code each of these into...
    // options: they can modify
    // assume everything is a modify?
    // no, I don't KNOW it was modified
    
    // strength = 0 - means it was destroyed, nothing can have strength 0.
    // return whether it was modified or not?
    // it is ALWAYS modified unless it was a NONE
    // just make an exception for none?
    
    // or, wait, do some of them have exceptions?
    
    // They should happen atomically, somehow. Take a snapshot of the objects? a clone?
    
    // You could either execute them here, but if you're going to return them
    NSMutableArray * interactionsOne = [self interactionsForSpell:SpellOne];
    NSMutableArray * interactionsTwo = [self interactionsForSpell:SpellTwo];
    
    return [interactionsOne arrayByAddingObjectsFromArray:interactionsTwo];
    
    // TODO: apply defaults (chicken)
}

-(PlayerEffect*)playerEffectForSpell:(Class)Spell {
    return [self.playerEffects objectForKey:Spell];
}

@end
