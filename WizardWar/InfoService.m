//
//  InfoService.m
//  WizardWar
//
//  Created by Sean Hess on 7/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "InfoService.h"

@implementation InfoService

+(NSString*)version {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

+(NSInteger)buildNumber {
    NSString * buildNumString = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    return [buildNumString intValue];
}

+(NSString*)buildDate {
    return [NSString stringWithUTF8String:__DATE__];
}

+(NSURL *)downloadURL {
    return [NSURL URLWithString:@"https://testflightapp.com/m/builds"];
}

@end
