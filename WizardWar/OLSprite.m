//
//  OLSprite.m
//  WizardWar
//
//  Created by Sean Hess on 8/14/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "OLSprite.h"

@implementation OLSprite
-(void) setDisplayFrame:(CCSpriteFrame*)frame
{
    [super setDisplayFrame:frame];
    [self.delegate sprite:self didChangeFrame:frame];
}

@end
