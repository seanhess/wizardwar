//
//  AppDelegate.m
//  WizardWar2
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "AppDelegate.h"
#import "MatchmakingViewController.h"
#import "cocos2d.h"
#import <Firebase/Firebase.h>
#import "WizardDirector.h"
#import "LandingViewController.h"
#import "MainNavViewController.h"
#import "AppStyle.h"
#import "UserService.h"
#import <Parse/Parse.h>
#import "MatchmakingViewController.h"
#import "ObjectStore.h"
#import "ConnectionService.h"
#import <ReactiveCocoa.h>
#import "AnalyticsService.h"
#import <TestFlight.h>
#import <FacebookSDK/FacebookSDK.h>
#import "OLUnitsService.h"
#import "InfoService.h"

// The director should belong to the app delegate or a singleton
// and you should manually unload or reload it

@interface AppDelegate () <UIAlertViewDelegate>
//@property (nonatomic, strong) MatchmakingViewController * matches;
@property (nonatomic, strong) CCDirectorIOS * director;
@property (nonatomic, strong) UINavigationController * rootNavigationController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"applicationDidFinishLaunchingWithOptions");
    
    // PARSE (must be before views)
    [Parse setApplicationId:@"3hsi88WR19iXGN11miDSH8B031uqyoBYBXHQe9bo" clientKey:@"CjkxlkZw0YOMdzdjJzhHfQm4vkPrA2ZWhY9n2Nfo"];
    [Parse setVersion:InfoService.buildNumber];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    
    
    [AppStyle customizeUIKitStyles];
    
    // OBJECT STORE ERRORS
    [RACAble(ObjectStore.shared, lastError) subscribeNext:^(NSError*error) {
        [self handleDataError:error];
    }];
    
    
    /// LOAD //////////////////
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    LandingViewController * landing = [LandingViewController new];
    MainNavViewController * navigationController = [[MainNavViewController alloc] initWithRootViewController:landing];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    self.rootNavigationController = navigationController;
    
    // SERVICES
    [ConnectionService.shared monitorDomain:[NSURL URLWithString:@"https://wizardwar.firebaseio.com"]];
    
    // INITIALIZE DIRECTOR
    NSLog(@"INITILIZE WITH BOUNDS %@", NSStringFromCGRect(self.window.bounds));
    Units * units = [[Units alloc] initWithRealSize:self.window.bounds.size];
    [OLUnitsService.shared setUnits:units];
    [WizardDirector initializeWithUnits:units];
    
    //    NSLog(@"FONT: %@",[UIFont fontNamesForFamilyName:@"ComicZineOT"]);
    //    NSLog(@"FONT: %@",[UIFont fontNamesForFamilyName:@"Comic Zine OT"]);
    //    NSLog(@"FAMLIES %@", [UIFont familyNames]);
    
    
    // No idea why it doesn't call didReceiveRemoteNotification on its own
    // This is only needed if they open a notification from a cold boot
    NSDictionary * remoteNotification = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (remoteNotification) [self application:application didReceiveRemoteNotification:remoteNotification];
    
    

    // ANALYTICS
    [AnalyticsService didFinishLaunching:launchOptions];
    [TestFlight takeOff:@"0b4e12af-c3aa-459a-891b-aa357a97e171"];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    
    NSString *deviceToken = [[newDeviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);    
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];    
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
    
    // If they allow it here, and current user exists
    [UserService.shared saveDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"***************** PUSHY TIME: %@", userInfo);
    [PFPush handlePush:userInfo];
    [self launchMatchmaking:userInfo[@"matchId"]];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"ERROR REGISTER %@", error);
    [UserService.shared setPushAccepted:NO];
}

- (void)launchMatchmaking:(NSString*)matchId {
    if ([[self.rootNavigationController.viewControllers lastObject] class] == [MatchmakingViewController class]) return;
    MatchmakingViewController * matchmaking = [MatchmakingViewController new];
    matchmaking.autoconnectToMatchId = matchId;
    [self.rootNavigationController pushViewController:matchmaking animated:YES];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");

    // I think this gives us a little more time to save stuff
    [ObjectStore.shared saveContext];
    [ConnectionService.shared setIsUserActive:NO];
    
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    [ConnectionService.shared setIsUserActive:YES];
    //    NSLog(@"applicationDidBEcom");
    //	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
     NSLog(@"applicationDidEnterBackground");
    [ConnectionService.shared setIsUserActive:NO];
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    NSLog(@"applicationWillEnterForeground");
    [ConnectionService.shared setIsUserActive:YES];
//    [self.matches reconnect];
    //	if( [navController_ visibleViewController] == director_ )
    //		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
    //	CC_DIRECTOR_END();
    [ObjectStore.shared saveContext];
    NSLog(@"applicationWillTerminate");
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    [ConnectionService.shared setDeepLinkUrl:url];
    return [PFFacebookUtils handleOpenURL:url];
}



-(void)handleDataError:(NSError*)error {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Reinstall" message:@"Data Model out of date. Please delete the app and reinstall" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    abort();
}


@end
