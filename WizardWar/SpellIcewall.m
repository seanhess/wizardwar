//
//  SpellIcewall.m
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellIcewall.h"

@implementation SpellIcewall

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.name = @"Wall of Ice";
    }
    return self;
}

@end
