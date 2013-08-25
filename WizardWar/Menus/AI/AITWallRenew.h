//
//  AITacticWallRenew.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

// Will renew a well that gets to 1, or recast the same type if it gets to 0
@interface AITWallRenew : NSObject <AITactic>
@property (nonatomic) BOOL createIfDead;
// tutorials don't want you to create another icewall :)
+(id)createIfDead;
@end
