//
//  MenuButton.m
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "MenuButton.h"
#import <QuartzCore/QuartzCore.h>
#import "AppStyle.h"
#import "Color.h"

@implementation MenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont fontWithName:FONT_LOVEYA size:16]];

    [self setBackgroundImage:AppStyle.blueNavColorImage forState:UIControlStateNormal];
//    [self setBackgroundImage:[AppStyle imageWithColor:UIColorFromRGB(0xFFFFFF)] forState:UIControlStateHighlighted];
    [self setTintColor:AppStyle.blueNavColor];
    self.layer.cornerRadius = 10.0f;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.borderWidth = 2.0f;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
