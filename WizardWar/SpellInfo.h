//
//  SpellType.h
//  WizardWar
//
//  Created by Sean Hess on 8/21/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpellInfo : NSObject
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) Class class;
@property (nonatomic, strong) NSString * name;

@property (nonatomic) float speed; // units per second
@property (nonatomic) float startOffsetPosition;  // in units
@property (nonatomic) float castDelay;  // in units
@property (nonatomic) NSInteger strength;
@property (nonatomic) NSInteger damage;
@property (nonatomic) BOOL targetSelf;
@property (nonatomic) BOOL heavy;

+(SpellInfo*)type:(NSString*)type class:(Class)class;
+(SpellInfo*)type:(NSString*)type;

@end
