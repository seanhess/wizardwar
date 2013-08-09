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
    self.cannotFindLocation = NO;
    if (location)
        [self.locationManager stopUpdatingLocation];
}

// kCLErrorDomain = 0 - location is unknown, but we will keep trying
/*
 kCLErrorLocationUnknown  = 0,         // location is currently unknown, but CL will keep trying
 kCLErrorDenied,                       // CL access has been denied (eg, user declined location use)
 kCLErrorNetwork,                      // general, network-related error
 kCLErrorHeadingFailure,               // heading could not be determined
 kCLErrorRegionMonitoringDenied,       // Location region monitoring has been denied by the user
 kCLErrorRegionMonitoringFailure,      // A registered region cannot be monitored
 kCLErrorRegionMonitoringSetupDelayed, // CL could not immediately initialize region monitoring
 kCLErrorRegionMonitoringResponseDelayed, // While events for this fence will be delivered, delivery will not occur immediately
 kCLErrorGeocodeFoundNoResult,         // A geocode request yielded no result
 kCLErrorGeocodeFoundPartialResult,    // A geocode request yielded a partial result
 kCLErrorGeocodeCanceled,              // A geocode request was cancelled
 kCLErrorDeferredFailed,               // Deferred mode failed
 kCLErrorDeferredNotUpdatingLocation,  // Deferred mode failed because location updates disabled or paused
 kCLErrorDeferredAccuracyTooLow,       // Deferred mode not supported for the requested accuracy
 kCLErrorDeferredDistanceFiltered,     // Deferred mode does not support distance filters
 kCLErrorDeferredCanceled,             // Deferred mode request canceled a previous request
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"LOCATION: (!) %@", error);
    self.accepted = NO;
    self.cannotFindLocation = (error.code == kCLErrorLocationUnknown);    
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
