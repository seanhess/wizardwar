//
//  Combo.m
//  WizardWar
//
//  Created by Sean Hess on 8/22/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "Combo.h"
#import "NSArray+Functional.h"
#import "Elements.h"

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
+(id)segments:(ComboSegments *)segments {
    Combo * combo = [Combo new];
    combo.segments = segments;
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

-(void)setSelected:(BOOL)selected element:(ElementType)element {
    if (element == Fire) self.fire = selected;
    else if (element == Air) self.air = selected;
    else if (element == Water) self.water = selected;
    else if (element == Heart) self.heart = selected;
    else if (element == Earth) self.earth = selected;
}

-(BOOL)isSelectedElement:(ElementType)element {
    if (element == Fire) return self.fire;
    if (element == Air) return self.air;
    if (element == Water) return self.water;
    if (element == Heart) return self.heart;
    if (element == Earth) return self.earth;
    return NO;
}

-(NSArray*)elements {
    NSMutableArray * elements = [NSMutableArray array];
    if (self.fire) [elements addObject:@(Fire)];
    if (self.air) [elements addObject:@(Air)];
    if (self.water) [elements addObject:@(Water)];
    if (self.heart) [elements addObject:@(Heart)];
    if (self.earth) [elements addObject:@(Earth)];
    return elements;
}

-(ElementType)startElement {
    ElementType startElement = Air;
    if (self.fire) {
        startElement = Fire;
        if (self.earth) {
            startElement = Earth;
            if (self.water) {
                startElement = Water;
                if (self.heart) {
                    startElement = Heart;
                }
            }
        }
    }
    return startElement;
}

+(NSArray*)elements:(NSArray*)elements sortByClockwiseDistanceFrom:(ElementType)start {
    NSArray * sorted = [elements sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ElementType one = [obj1 intValue];
        ElementType two = [obj2 intValue];
        NSInteger distanceOne = [self clockwiseDistance:one fromStart:start];
        NSInteger distanceTwo = [self clockwiseDistance:two fromStart:start];
        if (distanceOne < distanceTwo) return NSOrderedAscending;
        return NSOrderedDescending;
    }];
    return sorted;
}

+(NSInteger)clockwiseDistance:(ElementType)element fromStart:(ElementType)start {
    NSInteger distance = element - start;
    if (distance < 0) distance = 5+distance;
    return distance;
}

@end


@interface ComboSegments ()
@property (nonatomic, strong) NSMutableDictionary * elements;
@end

@implementation ComboSegments

-(id)init {
    if ((self = [super init])) {
        self.elements = [NSMutableDictionary new];
    }
    return self;
}

+(id)all {
    ComboSegments * segments = [ComboSegments new];
    [segments element:Fire and:Air connected:YES];
    [segments element:Fire and:Water connected:YES];
    [segments element:Fire and:Heart connected:YES];
    [segments element:Fire and:Earth connected:YES];
    [segments element:Air and:Water connected:YES];
    [segments element:Air and:Heart connected:YES];
    [segments element:Air and:Earth connected:YES];
    [segments element:Water and:Heart connected:YES];
    [segments element:Water and:Earth connected:YES];
    [segments element:Heart and:Earth connected:YES];
    return segments;
}

-(ComboSelectedElements*)connections:(ElementType)element {
    ComboSelectedElements * selected = self.elements[[Elements elementId:element]];
    if (!selected) {
        selected = [ComboSelectedElements new];
        self.elements[[Elements elementId:element]] = selected;
    }
    return selected;
}

-(void)element:(ElementType)element1 and:(ElementType)element2 connected:(BOOL)connected {
    ComboSelectedElements * selectedOne = [self connections:element1];
    ComboSelectedElements * selectedTwo = [self connections:element2];
    
    [selectedOne setSelected:connected element:element2];
    [selectedTwo setSelected:connected element:element1];
}

-(BOOL)isEqual:(ComboSegments*)object {
    for (NSString * elementId in self.elements.allKeys) {
        ElementType element = [Elements elementWithId:elementId];
        ComboSelectedElements * selectedSelf = [self connections:element];
        ComboSelectedElements * selectedOther = [object connections:element];
        
        if (![selectedSelf isEqual:selectedOther]) return NO;
    }
    return YES;
}

-(NSArray*)segmentsArray {
    
    NSMutableArray * segments = [NSMutableArray array];
    NSArray * elements = self.elements.allKeys;
    
    for (int i = 0; i < elements.count; i++) {
        ElementType startElement = [Elements elementWithId:elements[i]];
        ComboSelectedElements * selected = [self connections:startElement];
        
        for (int j = i+1; j < elements.count; j++) {
            ElementType endElement = [Elements elementWithId:elements[j]];
            
            if ([selected isSelectedElement:endElement]) {
                ComboSegment * segment = [ComboSegment new];
                segment.start = startElement;
                segment.end = endElement;
                [segments addObject:segment];
            }
        }
        
    }
    
    return segments;
}

@end


@implementation ComboSegment

@end


