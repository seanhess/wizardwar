//
//  Tutorial.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIService.h"
#import "AIOpponent.h"

@interface Tutorial : AIOpponent
@property (nonatomic, strong) NSArray * steps;
@property (nonatomic) NSInteger currentStepIndex;
-(void)loadStep:(NSInteger)stepIndex;
@end
