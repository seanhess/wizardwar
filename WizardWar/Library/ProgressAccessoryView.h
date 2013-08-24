//
//  QuestLevelProgressView.h
//  WizardWar
//
//  Created by Sean Hess on 8/23/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DDProgressView.h>

@interface ProgressAccessoryView : UIView
@property (nonatomic, strong) UILabel * label;
@property (nonatomic, strong) DDProgressView * progressView;
@property (nonatomic) CGFloat progressPadding;

@property (nonatomic, strong) UIColor * progressColor;

@property (nonatomic) CGRect topHalfFrame;
@property (nonatomic) CGRect bottomHalfFrame;
@property (nonatomic) CGRect centerFrame;

@property (nonatomic) BOOL alignCenter; // default is no
@property (nonatomic) UIFont * defaultFont;
@property (nonatomic) BOOL showLock;
@end
