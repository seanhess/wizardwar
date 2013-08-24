//
//  RACHelpers.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


#define RACMapExists ^id(id value) { return @(value != nil); }
#define RACFilterExists ^BOOL(id value) { return value != nil; }

#define RACMapNot ^id(NSNumber* value) { return @(!value.intValue); }


@interface RACHelpers : NSObject

@end
