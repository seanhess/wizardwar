//
//  User.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Objectable.h"
#import <CoreLocation/CoreLocation.h>

@interface User : NSObject <Objectable>
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * userId;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@end
