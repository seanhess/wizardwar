//
//  PentEmblem.h
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Elements.h"

typedef enum EmblemStatus {
    EmblemStatusNormal,
    EmblemStatusHighlight,
    EmblemStatusDisabled
} EmblemStatus;

@interface PentEmblem : UIImageView

@property (strong, nonatomic) NSString* elementId;
@property (nonatomic) EmblemStatus status;

@end
