//
//  LocationService.h
//  WizardWar
//
//  Created by Sean Hess on 6/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationService : NSObject

@property (nonatomic, strong) CLLocation * location;
@property (nonatomic) BOOL denied;
@property (nonatomic, readonly) BOOL hasLocation;

+ (LocationService *)shared;
- (void)connect;

- (CLLocationDistance)distanceFrom:(CLLocation*)location;
- (NSString*)distanceString:(CLLocationDistance)distance;

@end
