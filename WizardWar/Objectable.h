//
//  Firebaseable.h
//  WizardWar
//
//  Created by Sean Hess on 5/20/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

// Kind of a silly name. Means you can turn it into a raw dictionary
@protocol Objectable <NSObject>
-(NSDictionary*)toObject;
-(void)setValuesForKeysWithDictionary:(NSDictionary*)keyedValues;
@end
