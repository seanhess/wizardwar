//
//  CCScene+Layers.m
//  WizardsDuel
//
//  Created by Sean Hess on 5/16/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "CCScene+Layers.h"

@implementation CCScene (Layers)

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) sceneWithLayer:(CCLayer *)layer
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

@end
