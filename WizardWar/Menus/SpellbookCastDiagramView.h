//
//  SpellbookCastDiagramView.h
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpellRecord.h"
#import "Elements.h"

#define SPELLBOOK_DIAGRAM_HEIGHT 320

@interface SpellbookCastDiagramView : UIView
@property (nonatomic, strong) SpellRecord * record;
@end
