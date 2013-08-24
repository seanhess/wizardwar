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
#import "ProgressAccessoryView.h"

@interface SpellbookProgressView : ProgressAccessoryView
@property (nonatomic, strong) SpellRecord * record;
@end
