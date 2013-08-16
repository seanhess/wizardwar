//
//  MultiplayerService.h
//  WizardWar
//
//  Created by Sean Hess on 5/29/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"
#import "Wizard.h"
#import <Firebase/Firebase.h>
#import "Multiplayer.h"

@interface MultiplayerService : NSObject <Multiplayer>
@property (nonatomic) NSTimeInterval simulatedLatency;
@property (nonatomic, strong) Firebase * root;
-(id)initWithRootRef:(Firebase*)rootRef;
@end
