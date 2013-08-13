//
//  Times.h
//  WizardWar
//
//  Created by Sean Hess on 5/27/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Objectable.h"

@interface GameTime : NSObject <Objectable>
@property (nonatomic) NSString * name;
@property (nonatomic) NSInteger nextTick;
@property (nonatomic) NSTimeInterval gameTime;
@property (nonatomic) NSTimeInterval nextTickTime;
@end
