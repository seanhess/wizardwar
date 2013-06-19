//
//  LocalParty.m
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "LocalParty.h"

@implementation LocalParty

-(id)init {
    self = [super init];
    if (self) {
        self.name = @"Local Party";
        self.partyId = @"local";
        self.members = @[];
    }
    return self;
}

@end
