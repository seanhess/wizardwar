//
//  Times.h
//  WizardWar
//
//  Created by Sean Hess on 5/27/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Objectable.h"

@interface PlayerTime : NSObject <Objectable>
@property (nonatomic) NSString * name;
@property (nonatomic) NSTimeInterval currentTime;
@property (nonatomic) NSTimeInterval dTimeTo; // time from the other player to this one
@property (nonatomic) NSTimeInterval dTimeFrom; // we guess that this is how long it will take
@property (nonatomic) BOOL accepted;
@end
