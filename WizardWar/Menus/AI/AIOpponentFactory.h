//
//  AIOpponentSettings.h
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIService.h"

@interface AIOpponentFactory : NSObject
@property (nonatomic, strong) Class AIType;
@property (nonatomic, strong) NSArray * tactics;
@property (nonatomic) NSUInteger colorRGB;
@property (nonatomic, strong) NSString * name;

-(id<AIService>)create;
+(id)withType:(Class)AIType;
+(id)withColor:(NSUInteger)color tactics:(NSArray*)tactics;
@end
