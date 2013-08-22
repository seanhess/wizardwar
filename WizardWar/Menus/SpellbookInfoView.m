//
//  SpellbookInfoView.m
//  WizardWar
//
//  Created by Sean Hess on 8/21/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellbookInfoView.h"
#import "SpellbookCastDiagramView.h"
#import "SpellbookService.h"

@interface SpellbookInfoView ()
@property (nonatomic, strong) SpellbookCastDiagramView * diagram;
@property (nonatomic, strong) UIImageView * imageView;
@end

@implementation SpellbookInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [UIColor redColor];
        [self initialize];
    }
    return self;
}

- (void)initialize {
    // Initialization code
    
    CGFloat padding = 4;
    
    CGRect halfLeft = self.bounds;
    halfLeft.size.width = self.bounds.size.width / 2 - 2*padding;
    halfLeft.size.height -= padding*2;
    halfLeft.origin.x = padding;
    halfLeft.origin.y = padding;

    CGRect halfRight = self.bounds;
    halfRight.size.width = self.bounds.size.width / 2;
    halfRight.origin.x = halfRight.size.width;
    
    self.diagram = [[SpellbookCastDiagramView alloc] initWithFrame:halfRight];
    self.diagram.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.diagram];
    
    self.imageView = [[UIImageView alloc] initWithFrame:halfLeft];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
}

- (void)setRecord:(SpellRecord *)record {
    _record = record;
    self.imageView.image = [UIImage imageNamed:[SpellbookService.shared spellIconName:record]];
    self.diagram.record = record;
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
