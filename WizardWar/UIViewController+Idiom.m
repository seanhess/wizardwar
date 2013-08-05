//
//  UIViewController+Idiom.m
//  WizardWar
//
//  Created by Sean Hess on 8/5/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "UIViewController+Idiom.h"

@implementation UIViewController (Idiom)

- (id)initWithNibPerIdiom:(NSString*)nibName {
    NSString * idiomExtension = @"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        idiomExtension = @"_ipad";
    }
    
    return [self initWithNibName:[NSString stringWithFormat:@"%@%@", nibName, idiomExtension] bundle:nil];
}

- (id)initPerIdoim {
    NSString * nibName = NSStringFromClass(self.class);
    return [self initWithNibPerIdiom:nibName];
}


@end
