//
//  LocationService.m
//  WizardWar
//
//  Created by Sean Hess on 6/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "LocationService.h"

@interface LocationService () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager * locationManager;

@end

@implementation LocationService

+ (LocationService *)shared {
    static LocationService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationService alloc] init];
    });
    return instance;
}

- (void)connect {
    self.locationManager = [[CLLocationManager alloc] init];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 100; // before being notified again
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.delegate = self;

    NSLog(@"LocationService: connect");
    if (status == kCLAuthorizationStatusAuthorized) {
        [self startMonitoring];
    }
}

- (void)startMonitoring {
    if (self.hasLocation) return;
    NSLog(@"LocationService: monitor");
    [self.locationManager startUpdatingLocation];
}

// We only need one reading
- (void)updateLocation:(CLLocation*)location {
    NSLog(@"LocationService: (+) %@", location);
    self.location = location;
    if (location)
        [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {    
    self.accepted = NO;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    self.accepted = (status == kCLAuthorizationStatusAuthorized);
    NSLog(@"LOCATION: (status) %i", status);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self updateLocation:locations.lastObject];
}

- (BOOL)hasLocation {
    return (self.location != nil);
}

- (CLLocationDistance)distanceFrom:(CLLocation*)location {
    return [self.location distanceFromLocation:location];
}

- (NSString*)distanceString:(CLLocationDistance)distance {
    NSString * units = @"m";
    
    if (distance < MAX_SAME_LOCATION_DISTANCE) {
        return @"HERE";
    }
    
    if (distance > 1000) {
        distance = distance / 1000;
        units = @"km";
    }
    
    return [NSString stringWithFormat:@"%i %@", (int)round(distance), units];
}

@end
