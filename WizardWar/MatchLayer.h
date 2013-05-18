//
//  MatchLayer.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "CCLayer.h"

@protocol MatchLayerDelegate
-(void)doneWithMatch;
@end

@interface MatchLayer : CCLayer
@property (nonatomic, weak) id<MatchLayerDelegate>delegate;
-(id)initWithMatchId:(NSString*)matchId playerName:(NSString*)playerName;
@end
