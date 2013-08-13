//
//  Times.h
//  WizardWar
//
//  Created by Sean Hess on 5/27/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Objectable.h"

@interface ClientTime : NSObject <Objectable>

// Client Time
@property (nonatomic) NSString * name;
@property (nonatomic) NSTimeInterval time;

// Host stuff
@property (nonatomic) NSTimeInterval error;
@end
