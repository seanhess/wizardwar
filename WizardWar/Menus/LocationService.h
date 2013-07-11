//
//  LocationService.h
//  WizardWar
//
//  Created by Sean Hess on 6/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define MAX_SAME_LOCATION_DISTANCE 100.0

@interface LocationService : NSObject

@property (nonatomic, strong) CLLocation * location;
@property (nonatomic) BOOL denied;
@property (nonatomic, readonly) BOOL hasLocation;

+ (LocationService *)shared;

- (void)connect;
- (void)startMonitoring;

- (CLLocationDistance)distanceFrom:(CLLocation*)location;
- (NSString*)distanceString:(CLLocationDistance)distance;

@end
