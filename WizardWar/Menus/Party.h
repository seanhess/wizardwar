//
//  Party.h
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Party : NSObject
@property (strong, nonatomic) NSString * partyId;
@property (strong, nonatomic) NSString * name;

// Only contains name and userId, not parties
// Look up the full info for the User to get parties
@property (strong, nonatomic) NSArray * members;
@end
