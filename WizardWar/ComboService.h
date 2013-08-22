//
//  ComboService.h
//  WizardWar
//
//  Created by Sean Hess on 8/22/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Elements.h"
#import "Spell.h"
#import "Combo.h"

@interface ComboService : NSObject
+ (ComboService *)shared;

- (void)addCombo:(Combo*)combo type:(NSString*)type;
- (Combo*)comboForType:(NSString*)type;
- (Spell*)spellForElements:(NSArray*)elements;
@end
