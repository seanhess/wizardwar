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
#import "AIAction.h"

// TODO: change tactics if you get damaged? Like, cast a new spell as soon as you are damaged

@protocol AITactic <NSObject>
-(AIAction*)suggestedAction:(AIGameState*)game;
@optional
-(AIAction*)preAction;
-(AIAction*)endAction:(BOOL)didWin;
@end