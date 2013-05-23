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
#import <Firebase/Firebase.h>
#import "WizardDirector.h"

// The director should belong to the app delegate or a singleton
// and you should manually unload or reload it

@interface AppDelegate ()
@property (nonatomic, strong) MatchmakingViewController * matches;
@property (nonatomic, strong) CCDirectorIOS * director;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.matches = [[MatchmakingViewController alloc] initWithNibName:@"MatchmakingViewController" bundle:nil];
    MainNavViewController * navigationController = [[MainNavViewController alloc] initWithRootViewController:self.matches];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    
    // INITIALIZE DIRECTOR
    [WizardDirector initializeWithBounds:self.window.bounds];
    
    return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
    [self.matches disconnect];
    // disconnect here!
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    //    NSLog(@"applicationDidBEcom");
    //	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
    NSLog(@"applicationDidEnterBackground");
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    NSLog(@"applicationWillEnterForeground");
    [self.matches reconnect];
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
    //	CC_DIRECTOR_END();
    NSLog(@"applicationWillTerminate");
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}


@end
