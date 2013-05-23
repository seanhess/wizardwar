//
//  TestLayer.m
//  WizardWar
//
//  Created by Sean Hess on 5/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "TestLayer.h"

@implementation TestLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	TestLayer *layer = [TestLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

-(id)init {
    self = [super init];
    if (self) {
        CCLabelTTF * label = [CCLabelTTF labelWithString:@"hello" fontName:@"Marker Felt" fontSize:36];
        label.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        [self addChild:label];
    }
    return self;
}

@end
