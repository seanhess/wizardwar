//
//  Elements.m
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Elements.h"

@implementation Elements

+(NSString*)comboId:(NSArray*)elements {
    NSMutableString * output = [NSMutableString new];
    for (NSString * element in elements) {
        [output appendString:element];
    }
    return output;
}

+(NSString*)elementId:(ElementType)element {
    if (element == Air) return AirId;
    else if (element == Earth) return EarthId;
    else if (element == Fire) return FireId;
    else if (element == Heart) return HeartId;
    else if (element == Water) return WaterId;
    else return nil;
}

+(ElementType)elementWithId:(NSString*)elementId {
    if ([elementId isEqualToString:AirId]) return Air;
    else if ([elementId isEqualToString:EarthId]) return Earth;
    else if ([elementId isEqualToString:FireId]) return Fire;
    else if ([elementId isEqualToString:HeartId]) return Heart;
    else if ([elementId isEqualToString:WaterId]) return Water;
    else return Air;
}

@end
