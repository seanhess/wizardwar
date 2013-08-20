//
//  SpellbookProgressView.h
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DDProgressView.h>
#import "SpellRecord.h"

@interface SpellbookProgressView : UIView
@property (nonatomic, strong) UILabel * label;
@property (nonatomic) CGFloat progress;

@property (nonatomic, strong) SpellRecord * record;
@property (nonatomic, strong) UIColor * progressColor;
@end
