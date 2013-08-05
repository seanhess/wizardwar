//
//  UIViewController+Idiom.h
//  WizardWar
//
//  Created by Sean Hess on 8/5/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Idiom)
- (id)initWithNibPerIdiom:(NSString*)nibName;
- (id)initPerIdoim; // uses the class name
@end
