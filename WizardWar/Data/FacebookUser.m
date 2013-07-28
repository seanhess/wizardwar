//
//  FacebookUser.m
//  WizardWar
//
//  Created by Sean Hess on 7/16/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "FacebookUser.h"


@implementation FacebookUser

@dynamic firstName;
@dynamic lastName;
@dynamic name;
@dynamic username;
@dynamic facebookId;
@dynamic user;

-(id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}


@end
