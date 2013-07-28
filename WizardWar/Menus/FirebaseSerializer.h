//
//  FirebaseSerializer.h
//  WizardWar
//
//  Created by Sean Hess on 7/28/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FirebaseSerializer : NSObject

+(void)updateObject:(NSObject*)object withDictionary:(NSDictionary*)dictionary;

@end
