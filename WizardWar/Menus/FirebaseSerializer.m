//
//  FirebaseSerializer.m
//  WizardWar
//
//  Created by Sean Hess on 7/28/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "FirebaseSerializer.h"

@implementation FirebaseSerializer

// safely updates it booyah
+(void)updateObject:(NSObject*)object withDictionary:(NSDictionary*)dictionary {
    for (NSString * key in dictionary.allKeys) {
        @try {
            [object setValue:dictionary[key] forKey:key];
        }
        @catch (NSException *exception) {
            NSLog(@"Object No Property: %@", exception.reason);
        }
        @finally {}
    }
}

@end
