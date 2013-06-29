//
//  ComicZineDoubleLabel.h
//  WizardWar
//
//  Created by Sean Hess on 6/29/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComicZineDoubleLabel : UIView
@property (nonatomic, strong) NSString * text;

+(UIView*)titleView:(NSString*)title navigationBar:(UINavigationBar*)navigationBar;
@end
