//
//  Combo.m
//  WizardWar
//
//  Created by Sean Hess on 8/22/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "Combo.h"
#import "NSArray+Functional.h"

@implementation Combo
+(id)exact:(NSArray*)elements {
    Combo * combo = [Combo new];
    combo.orderedElements = elements;
    return combo;
}
+(id)basic5:(ElementType)startElement {
    Combo * combo = [Combo new];
    combo.startElement = startElement;
    return combo;
}
+(id)common:(NSArray*)elements {
    Combo * combo = [Combo new];
    combo.selectedElements = [ComboSelectedElements elements:elements];
    return combo;
}
+(id)air:(BOOL)air heart:(BOOL)heart water:(BOOL)water earth:(BOOL)earth fire:(BOOL)fire {
    Combo * combo = [Combo new];
    ComboSelectedElements * selected = [ComboSelectedElements new];
    selected.fire = fire;
    selected.heart = heart;
    selected.air = air;
    selected.earth = earth;
    selected.water = water;
    combo.selectedElements = selected;
    return combo;
}
-(NSString*)description {
    return [NSString stringWithFormat:@"<Combo:%@>", self.spellType];
}
@end


@implementation ComboSelectedElements
-(BOOL)isEqual:(ComboSelectedElements*)object {
    return object.earth == self.earth && object.air == self.air && object.water == self.water && object.fire == self.fire && object.heart == self.heart;
}

+ (ComboSelectedElements*)elements:(NSArray*)elements {
    ComboSelectedElements* selected = [ComboSelectedElements new];
    [elements forEach:^(NSNumber*elementNumber) {
        ElementType element = elementNumber.intValue;
        if (element == Fire) selected.fire = YES;
        if (element == Air) selected.air = YES;
        if (element == Water) selected.water = YES;
        if (element == Earth) selected.earth = YES;
        if (element == Heart) selected.heart = YES;
    }];
    return selected;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<ComboSelectedElements> %i%i%i%i%i", self.air, self.heart, self.water, self.earth, self.fire];
}


@end
