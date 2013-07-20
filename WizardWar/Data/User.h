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
@class Challenge;

@interface User : NSManagedObject <Objectable>

@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic) BOOL isOnline;
@property (nonatomic) double locationLatitude;
@property (nonatomic) double locationLongitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic) int16_t friendPoints;
@property (nonatomic) CLLocationDistance distance;
@property (nonatomic) NSTimeInterval updated;
@property (nonatomic) int32_t colorRGB; // hex rgb value
@property (nonatomic) BOOL isMain;
@property (nonatomic, retain) NSString* facebookId;

@property (nonatomic) BOOL isGuestAccount;

@property (nonatomic, retain) Challenge *challenge;
@property (nonatomic, retain) NSString *activeMatchId;

// Transient Properties and methods
// some are relative to the current user
@property (nonatomic, readonly) CLLocation * location;
@property (nonatomic, readonly) BOOL isFriend;
@property (nonatomic) BOOL isClose;
@property (nonatomic, strong) UIColor * color;

-(NSDictionary*)toLobbyObject;

@end
