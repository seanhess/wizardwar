//
//  PentEmblem.h
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Elements.h"

#define MAX_MANA 3

typedef enum EmblemStatus {
    EmblemStatusNormal,
    EmblemStatusSelected,
    EmblemStatusDisabled
} EmblemStatus;

@interface PentEmblem : UIView

@property (nonatomic, strong) UIImage * image;
@property (nonatomic) ElementType element;
@property (nonatomic) EmblemStatus status;
@property (nonatomic) NSInteger mana;
@property (nonatomic) CGSize size;

-(void)flashHighlight;

@end
