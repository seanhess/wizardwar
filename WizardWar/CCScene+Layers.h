//
//  CCScene+Layers.h
//  WizardsDuel
//
//  Created by Sean Hess on 5/16/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "cocos2d.h"
#import "CCScene.h"

@interface CCScene (Layers)

// Helper class method that creates a Scene with the layer as the only child.
+(CCScene *) sceneWithLayer:(CCLayer*)layer;

@end
