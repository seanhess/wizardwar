//
//  AIStrategy.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"
#import "AIGameState.h"

// Should be composable, right?
// so... what does that mean?
// It means you could load a particular offensive strategy and a particular defensive strategy

// AI CAN: cast spells, talk

@interface AIAction : NSObject
@property (nonatomic) NSInteger weight; // how much we want to do this action
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) Spell * spell;
@property (nonatomic) NSTimeInterval timeRequired; // the castDelay, etc. 0 for message.
+(id)spell:(Spell*)spell weight:(NSInteger)weight time:(NSTimeInterval)time;
+(id)spell:(Spell*)spell;
+(id)message:(NSString*)message;
@end


@protocol AITactic <NSObject>
-(AIAction*)suggestedAction:(AIGameState*)game;
@end