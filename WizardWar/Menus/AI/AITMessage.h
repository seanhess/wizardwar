//
//  AITMessageStart.h
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

// a ... specific hit message?
// would be cooler if random
// and maybe it's nothing!
@interface AITMessage : NSObject <AITactic>
@property (nonatomic, strong) NSArray * start;
@property (nonatomic, strong) NSMutableArray * cast;
@property (nonatomic, strong) NSMutableArray * castOther;
@property (nonatomic, strong) NSMutableArray * hits;
@property (nonatomic, strong) NSMutableArray * wounds;
@property (nonatomic, strong) NSArray * win;
@property (nonatomic, strong) NSArray * lose;
@property (nonatomic) float chance;
+(id)withStart:(NSArray*)messages;
+(id)withCast:(NSArray*)messages chance:(float)chance;
+(id)withCastOther:(NSArray*)messages chance:(float)chance;
+(id)withHits:(NSArray*)messages chance:(float)chance;
+(id)withWounds:(NSArray*)messages chance:(float)chance;
+(id)withWin:(NSArray*)messages;
+(id)withLose:(NSArray*)messages;

@end
