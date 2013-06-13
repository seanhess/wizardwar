//
//  Simulated.h
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Simulated <NSObject>
-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval;
@end
