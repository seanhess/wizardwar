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
    // return [NSString stringWithUTF8String:__DATE__];
    NSString * version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
//    NSString * date = self.buildDate;
    return [NSString stringWithFormat:@"%@ (%@)", version, build];
}

+(NSString*)buildDate {
    return [NSString stringWithUTF8String:__DATE__];
}

@end
