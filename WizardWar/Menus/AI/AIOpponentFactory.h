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
@property (nonatomic, strong) NSString * name;
@property (nonatomic) NSUInteger colorRGB;
@property (nonatomic, strong) NSArray*(^tactics)(void);
@property (nonatomic, strong) NSString * environment;

-(id<AIService>)create;
+(id)withType:(Class)AIType;
+(id)withColor:(NSUInteger)color environment:(NSString*)environment tactics:(NSArray*(^)(void))tactics;
+(id)withColor:(NSUInteger)color tactics:(NSArray*(^)(void))tactics;
@end
