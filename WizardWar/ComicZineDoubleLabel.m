//
//  ComicZineDoubleLabel.m
//  WizardWar
//
//  Created by Sean Hess on 6/29/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "ComicZineDoubleLabel.h"
#import "AppStyle.h"

@interface ComicZineDoubleLabel ()
@property (strong, nonatomic) UILabel * foregroundLabel;
@property (strong, nonatomic) UILabel * backgroundLabel;
@end

@implementation ComicZineDoubleLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5.0, -2.35, self.frame.size.width, self.self.frame.size.height)];
    self.backgroundLabel.textAlignment = NSTextAlignmentCenter;
    self.backgroundLabel.textColor = [UIColor colorWithRed:0.9490 green:0.8353 blue:0.3098 alpha:1.0000];
    self.backgroundLabel.backgroundColor = [UIColor clearColor];
    self.backgroundLabel.font = [UIFont fontWithName:@"ComicZineSolid-Regular" size:(29.0)];
    self.backgroundLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.backgroundLabel];
    
    self.foregroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5.0, 1, self.frame.size.width, self.self.frame.size.height)];
    self.foregroundLabel.textAlignment = NSTextAlignmentCenter;
    self.foregroundLabel.textColor = [UIColor blackColor];
    self.foregroundLabel.backgroundColor = [UIColor clearColor];
    self.foregroundLabel.font = [UIFont fontWithName:@"ComicZineOT" size:(29.0)];
    self.foregroundLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
   [self addSubview:self.foregroundLabel];
}

- (void)setText:(NSString *)text {
    _text = text;
    self.backgroundLabel.text = text;
    self.foregroundLabel.text = text;
}

+(UIView*)titleViewWithViewController:(UIViewController*)viewController {
    CGFloat height = viewController.navigationController.navigationBar.frame.size.height;
    CGFloat width = viewController.view.frame.size.width;
    
    ComicZineDoubleLabel * label = [[ComicZineDoubleLabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    label.text = viewController.title;
    return label;
}

@end
