//
//  RACSignal+Filters.h
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "RACSignal.h"

@interface RACSignal (Filters)
// sets to [NSNumber numberWithInt:0] if it doesn't exist]
// works for int and bool
- (RACSignal*)safe;

// filters by exists, so it won't even get called if it doesn't exist
- (RACSignal*)exists;
@end
