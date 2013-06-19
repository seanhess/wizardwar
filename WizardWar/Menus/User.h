//
//  User.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Objectable.h"

@interface User : NSObject <Objectable>
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * userId;

// Only contains partyId and name, not members
// Look up the party info to get everything
@property (strong, nonatomic) NSArray * parties;
@end
