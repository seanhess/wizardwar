//
//  SpellEffectService.h
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpellEffect.h"
#import "PlayerEffect.h"
#import "SpellInteraction.h"
#import "SpellInfo.h"

#define Teddy @"teddybear"
#define Undies @"wizard-undies"
#define Hotdog @"hotdog"
#define Chicken @"chicken"
#define Rainbow @"rainbow"
#define Fireball @"fireball"
#define Lightning @"lightning"
#define Fist @"fist"
#define Helmet @"helmet"
#define Earthwall @"earthwall"
#define Firewall @"firewall"
#define Bubble @"bubble"
#define Icewall @"icewall"
#define Monster @"ogre"
#define Vine @"vine"
#define Windblast @"windblast"
#define Invisibility @"invisibility"
#define Heal @"heal"
#define Levitate @"levitate"
#define Sleep @"pillow"
#define CaptainPlanet @"captain-planet"

@interface SpellEffectService : NSObject

+ (SpellEffectService *)shared;

@property (nonatomic, strong) NSArray * allSpellTypes;


-(NSArray*)interactionsForSpell:(NSString*)SpellOne andSpell:(NSString*)SpellTwo;
-(PlayerEffect*)playerEffectForSpell:(NSString*)Spell;

-(SpellInfo*)infoForType:(NSString*)type;

@end
