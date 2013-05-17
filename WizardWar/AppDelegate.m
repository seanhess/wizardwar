//
//  AppDelegate.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright The LAB 2013. All rights reserved.
//


#import "AppDelegate.h"
#import "MatchmakingViewController.h"

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    UIWindow * window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MatchmakingViewController * matches = [MatchmakingViewController new];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:matches];
    
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
    
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

