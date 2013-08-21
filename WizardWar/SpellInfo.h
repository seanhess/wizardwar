//
//  SpellType.h
//  WizardWar
//
//  Created by Sean Hess on 8/21/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerEffect.h"

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

@interface SpellInfo : NSObject
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) Class class;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) PlayerEffect * effect;

@property (nonatomic) float speed; // units per second
@property (nonatomic) float startOffsetPosition;  // in units
@property (nonatomic) float castDelay;  // in units
@property (nonatomic) NSInteger strength;
@property (nonatomic) NSInteger damage;
@property (nonatomic) BOOL targetSelf;
@property (nonatomic) BOOL heavy;
@property (nonatomic) BOOL isWall;

+(SpellInfo*)type:(NSString*)type class:(Class)class;
+(SpellInfo*)type:(NSString*)type;

@end
