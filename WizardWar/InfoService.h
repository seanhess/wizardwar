//
//  InfoService.h
//  WizardWar
//
//  Created by Sean Hess on 7/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoService : NSObject

+(NSString*)version;
+(NSString*)buildDate;
+(NSInteger)buildNumber;
+(NSURL*)downloadURL;
+(NSString*)supportEmail;
+(NSString*)firebaseUrl;
+(NSString*)openSourceUrl;
+(NSString*)creditsUrl;
+(NSString*)appId;

@end
