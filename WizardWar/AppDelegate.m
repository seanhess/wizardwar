//
//  AppDelegate.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright The LAB 2013. All rights reserved.
//


#import "AppDelegate.h"
#import "MatchmakingViewController.h"
#import "MainNavViewController.h"
#import <Firebase/Firebase.h>

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    UIWindow * window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MatchmakingViewController * matches = [MatchmakingViewController new];
    MainNavViewController * navigationController = [[MainNavViewController alloc] initWithRootViewController:matches];
    
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
    
    
    // Create a reference to a Firebase location
    Firebase* f = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/"];

    // Write data to Firebase
    [f setValue:@"Do you have data? You'll love Firebase."];

    // Read data and react to changes
    [f observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
          NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
    }];
    
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

