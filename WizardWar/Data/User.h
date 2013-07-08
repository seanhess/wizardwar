//
//  User.h
//  WizardWar
//
//  Created by Sean Hess on 7/8/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "Objectable.h"

@interface User : NSManagedObject <Objectable>

@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic) BOOL isOnline;
@property (nonatomic) double locationLatitude;
@property (nonatomic) double locationLongitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) NSTimeInterval updated;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic) int16_t friendPoints;

@property (nonatomic, readonly) CLLocation * location;
@property (nonatomic, readonly) BOOL isFriend;

-(NSDictionary*)toLobbyObject;

@end
