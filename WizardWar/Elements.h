//
//  Elements.h
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ElementType {
    ElementTypeNone,
    Air,
    Earth,
    Fire,
    Heart,
    Water
} ElementType;

#define AirId @"A"
#define EarthId @"E"
#define FireId @"F"
#define HeartId @"H"
#define WaterId @"W"

@interface Elements : NSObject

// gives you an id for a certain combo
+(NSString*)comboId:(NSArray*)elements;
+(NSString*)elementId:(ElementType)element;
+(ElementType)elementWithId:(NSString*)elementId;

@end
