//
//  AnalyticsService.m
//  WizardWar
//
//  Created by Sean Hess on 7/16/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "AnalyticsService.h"
#import "TestFlight.h"

@implementation AnalyticsService

+(void)didFinishLaunching:(NSDictionary *)launchOptions {

}

+(void)event:(NSString *)name {
    [TestFlight passCheckpoint:name];
}

@end
