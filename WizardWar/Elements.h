//
//  Elements.h
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Elements : NSObject

// gives you an id for a certain combo
+(NSString*)comboId:(NSArray*)elements;

+(NSString*)fire;
+(NSString*)water;
+(NSString*)air;
+(NSString*)heart;
+(NSString*)earth;

@end
