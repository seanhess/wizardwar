//
//  LocalPartyService.h
//  WizardWar
//
//  Created by Sean Hess on 6/1/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalParty.h"

// Loads the locals yo
@interface LocalPartyService : NSObject
@property (nonatomic, strong) LocalParty * party;

+ (LocalPartyService *)shared;
- (void)connect;

@end