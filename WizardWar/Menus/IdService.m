//
//  IdService.m
//  WizardWar
//
//  Created by Sean Hess on 6/21/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "IdService.h"

static NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@implementation IdService

+(NSString *) randomId:(int)length {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

@end
