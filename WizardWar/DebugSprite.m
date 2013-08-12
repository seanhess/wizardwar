//
//  DebugSprite.m
//  WizardWar
//
//  Created by Sean Hess on 8/12/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "DebugSprite.h"
#import "cocos2d.h"

@implementation DebugSprite

-(void)draw {
    ccDrawColor4B(255, 0, 0, 255);
    glLineWidth(5.0f);
    ccDrawCircle(ccp(0,0), 3.0f, CC_DEGREES_TO_RADIANS(360), 1, YES);
    //ccDrawRect(ccp(0,0), ccpAdd(ccp(0,0), ccp(10, 10)));
}

@end
