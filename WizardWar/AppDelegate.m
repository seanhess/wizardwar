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

@interface AppDelegate ()
@property (nonatomic, strong) UIImageView * splash;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSString * imageName = @"Default.png";
    if (UIScreen.mainScreen.bounds.size.height > 480) {
        imageName = @"Default-568h.png";
    }
    
    self.splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    
    MatchmakingViewController * matches = [[MatchmakingViewController alloc] initWithNibName:@"MatchmakingViewController" bundle:nil];
    MainNavViewController * navigationController = [[MainNavViewController alloc] initWithRootViewController:matches];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    
    [self.window addSubview:self.splash];
    
    [self performSelector:@selector(hideSplash) withObject:self afterDelay:1.0];
    
    return YES;
}

-(void) hideSplash {
    [UIView animateWithDuration:0.2 animations:^{
        self.splash.alpha = 0;
    } completion:^(BOOL finished) {
        [self.splash removeFromSuperview];
    }];
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
    NSLog(@"ACTIVE");
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
