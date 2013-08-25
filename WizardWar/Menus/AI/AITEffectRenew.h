//
//  AITEffectRenew.h
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AITactic.h"
#import "PlayerEffect.h"

@interface AITEffectRenew : NSObject <AITactic>
@property (nonatomic, strong) PlayerEffect * effect;
@property (nonatomic, strong) NSString * spellType;
+(id)effect:(PlayerEffect*)effect spell:(NSString*)spell;
@end
