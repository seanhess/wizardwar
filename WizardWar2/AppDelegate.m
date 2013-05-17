//
//  AppDelegate.m
//  WizardWar2
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "AppDelegate.h"
#import "MatchmakingViewController.h"
#import "MainNavViewController.h"
#import "cocos2d.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    MatchmakingViewController * matches = [MatchmakingViewController new];
    MainNavViewController * navigationController = [[MainNavViewController alloc] initWithRootViewController:matches];
    
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
    //	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
    //	CC_DIRECTOR_END();
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}


@end
