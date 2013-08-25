//
//  Combo.h
//  WizardWar
//
//  Created by Sean Hess on 8/22/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Elements.h"




@interface ComboSelectedElements : NSObject
@property (nonatomic) BOOL fire;
@property (nonatomic) BOOL air;
@property (nonatomic) BOOL water;
@property (nonatomic) BOOL heart;
@property (nonatomic) BOOL earth;
+(id)elements:(NSArray*)elements;
-(void)setSelected:(BOOL)selected element:(ElementType)element;
-(BOOL)isSelectedElement:(ElementType)element;
-(NSArray*)elements;
@end


@interface ComboSegment : NSObject
@property (nonatomic) ElementType start;
@property (nonatomic) ElementType end;
@end

@interface ComboSegments : NSObject
+(id)all; // lets you start with all selected and change from there
-(void)element:(ElementType)element1 and:(ElementType)element2 connected:(BOOL)connected;
// returns an array of ComboSegment, without duplicates :(
-(NSArray*)segmentsArray;
@end


@interface Combo : NSObject
@property (nonatomic, strong) NSString * spellType;
@property (nonatomic) ElementType startElement;
@property (nonatomic, strong) NSArray * orderedElements;
@property (nonatomic, strong) ComboSegments * segments;
@property (nonatomic, strong) ComboSelectedElements * selectedElements;
+(id)exact:(NSArray*)elements;
+(id)basic5:(ElementType)startElement;
+(id)common:(NSArray*)elements;
+(id)air:(BOOL)air heart:(BOOL)heart water:(BOOL)water earth:(BOOL)earth fire:(BOOL)fire;
+(id)segments:(ComboSegments*)segments;
@end


