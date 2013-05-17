//
//  Match.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Match : NSObject
@property (nonatomic, strong) NSMutableArray * players;
@property (nonatomic, strong) NSMutableArray * spells;

-(void)update:(NSTimeInterval)dt;
@end
