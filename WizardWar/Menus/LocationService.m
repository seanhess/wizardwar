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
    // locationManager update as location
    self.locationManager = [[CLLocationManager alloc] init];

    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 100; // before being notified again
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.delegate = self;
//    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)updateLocation:(CLLocation*)location {
    CLLocationCoordinate2D coordinate = [location coordinate];
    NSLog(@"UPDATED LOCATION %f %f", coordinate.latitude, coordinate.longitude);
    self.latitude = coordinate.latitude;
    self.longitude = coordinate.longitude;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"LOCATION: (error) %@", error);
    
    self.denied = YES;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSLog(@"LOCATION: (status) %i", status);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"LOCATION: (update)");
    [self updateLocation:locations.lastObject];
}

- (BOOL)hasLocation {
    return (self.latitude);
}

@end
