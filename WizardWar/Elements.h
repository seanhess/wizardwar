//
//  Elements.h
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum Element {
    ElementFire = 1,
    ElementWater,
    ElementAir,
    ElementHeart,
    ElementEarth,
} Element;

@interface Elements : NSObject

// gives you an id for a certain combo
-(NSString*)comboId:(NSArray*)elements;

@end
