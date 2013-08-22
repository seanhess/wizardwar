//
//  ComboService.m
//  WizardWar
//
//  Created by Sean Hess on 8/22/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//


#import "ComboService.h"
#import "NSArray+Functional.h"




@interface ComboService ()
@property (nonatomic, strong) NSMutableArray * commonCombos;
@property (nonatomic, strong) NSMutableArray * exactCombos;
@property (nonatomic, strong) NSMutableArray * basic5Combos;
@property (nonatomic, strong) NSMutableArray * segmentCombos;
@property (nonatomic, strong) NSMutableDictionary * combosByType;
@end

@implementation ComboService
+ (ComboService *)shared {
    static ComboService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ComboService alloc] init];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        self.commonCombos = [NSMutableArray array];
        self.exactCombos = [NSMutableArray array];
        self.basic5Combos = [NSMutableArray array];
        self.segmentCombos = [NSMutableArray array];
        self.combosByType = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addCombo:(Combo *)combo type:(NSString *)type {
    combo.spellType = type;
    if (combo.selectedElements) {
//        NSLog(@"Combo Common %@", combo);
        [self.commonCombos addObject:combo];
    }
    else if (combo.startElement) {
//        NSLog(@"Combo Basic5 %@", combo);
        [self.basic5Combos addObject:combo];
    }
    else if (combo.orderedElements) {
//        NSLog(@"Combo Exact %@", combo);
        [self.exactCombos addObject:combo];
    }
    else if (combo.segments) {
        [self.segmentCombos addObject:combo];
    }
    else {
        NSLog(@"Unrecognized Combo! %@", combo);
        NSAssert(false, @"Unrecognized Combo");
    }
    [self.combosByType setObject:combo forKey:type];
}

- (Combo*)comboForType:(NSString*)type {
    return [self.combosByType objectForKey:type];
}

- (Spell*)spellForElements:(NSArray*)elements {
    Combo * combo       = [self matchExactCombo:elements];
    if (!combo) combo   = [self matchSegmentCombo:elements];
    if (!combo) combo   = [self matchBasic5Combo:elements];
    if (!combo) combo   = [self matchCommonCombo:elements];
    if (!combo) return nil;
    return [Spell fromType:combo.spellType];
}

- (Combo*)matchSegmentCombo:(NSArray*)elements {
    ComboSegments * segments = [ComboSegments new];
    ElementType lastElement = ElementTypeNone;
    for (NSNumber * elementNumber in elements) {
        ElementType element = elementNumber.intValue;
        if (lastElement) {
            [segments element:lastElement and:element connected:YES];
        }
        lastElement = element;
    }
    
    return [self.segmentCombos find:^BOOL(Combo * combo) {
        return [combo.segments isEqual:segments];
    }];
}

- (Combo*)matchCommonCombo:(NSArray*)elements {
    ComboSelectedElements * selected = [ComboSelectedElements elements:elements];
    
    return [self.commonCombos find:^BOOL(Combo*combo) {
        return [combo.selectedElements isEqual:selected];
    }];
}

- (Combo*)matchExactCombo:(NSArray*)elements {
    return [self.exactCombos find:^BOOL(Combo*combo) {
        return [combo.orderedElements isEqualToArray:elements];
    }];
}

- (Combo*)matchBasic5Combo:(NSArray*)elements {
    if (elements.count < 5) return nil;

    // All must be selected
    ComboSelectedElements * selected = [ComboSelectedElements elements:elements];
    if (!(selected.fire && selected.air && selected.water && selected.heart && selected.earth)) return nil;

    // And the first element must match
    ElementType startElement = [self startElement:elements];
    return [self.basic5Combos find:^BOOL(Combo*combo) {
        return combo.startElement == startElement;
    }];
}

- (ElementType)startElement:(NSArray*)element {
    return [[element objectAtIndex:0] intValue];
}

@end

