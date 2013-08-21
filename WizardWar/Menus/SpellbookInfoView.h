//
//  SpellbookInfoView.h
//  WizardWar
//
//  Created by Sean Hess on 8/21/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpellRecord.h"

#define SPELLBOOK_INFO_HEIGHT 160

@interface SpellbookInfoView : UIView
@property (nonatomic, strong) SpellRecord * record;

@end
