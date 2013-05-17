//
//  Match.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"

@protocol MatchDelegate
-(void)didRemoveSpell:(Spell*)spell;
@end

@interface Match : NSObject
@property (nonatomic, strong) NSMutableArray * players;
@property (nonatomic, strong) NSMutableArray * spells;
@property (nonatomic, weak) id<MatchDelegate> delegate;
-(void)update:(NSTimeInterval)dt;
-(void)addSpell:(Spell*)spell;
-(id)initWithId:(NSString*)id;
@end
