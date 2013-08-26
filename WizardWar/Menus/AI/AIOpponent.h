//
//  AIOpponent.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIService.h"
#import "AIGameState.h"

@interface AIOpponent : NSObject <AIService>
@property (nonatomic) AIGameState * game;
@property (nonatomic) NSArray * tactics;
-(id)initWithName:(NSString*)name color:(NSUInteger)color tactics:(NSArray*)tactics;
@end
