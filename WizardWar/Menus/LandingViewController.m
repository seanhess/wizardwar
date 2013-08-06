//
//  LandingViewController.m
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "LandingViewController.h"
#import "Wizard.h"
#import "MatchViewController.h"
#import "MatchmakingViewController.h"
#import "UserService.h"
#import "LobbyService.h"
#import "LocationService.h"
#import "ChallengeService.h"
#import "LobbyService.h"
#import "SettingsViewController.h"
#import "UserFriendService.h"
#import "AnalyticsService.h"
#import "UIViewController+Idiom.h"

#import <FacebookSDK/FacebookSDK.h>
#import "NSArray+Functional.h"

@interface LandingViewController ()  <FBFriendPickerDelegate>
@end

@implementation LandingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [UserService.shared connect];
    [UserFriendService.shared checkFBStatus:UserService.shared.currentUser];
    [LobbyService.shared connect];
    [LocationService.shared connect];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [LobbyService.shared leaveLobby:UserService.shared.currentUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapQuest:(id)sender {
    Wizard * ai = [Wizard new];
    ai.name = @"Zorlak Bot";
    ai.wizardType = WIZARD_TYPE_ONE;
    
    [AnalyticsService event:@"PracticeGameTap"];
    
    MatchViewController * match = [[MatchViewController alloc] initPerIdoim];
    [match startMatchAsWizard:UserService.shared.currentWizard withAI:ai];
    [self.navigationController presentViewController:match animated:YES completion:nil];
}

//- (IBAction)didTapParties:(id)sender {
//    User * user = [User new];
//    user.name = @"fake";
//    user.userId = @"fake";
//    user.parties = @[];
//    
//    PartiesViewController * parties = [[PartiesViewController alloc] initWithUser:user];
//    [self.navigationController pushViewController:parties animated:YES];
//}

- (IBAction)didTapMultiplayer:(id)sender {
    __weak LandingViewController * wself = self;
    MatchmakingViewController * matchmaking = [MatchmakingViewController new];
    
    if ([UserService shared].isAuthenticated) {
        [self.navigationController pushViewController:matchmaking animated:YES];
    } else {
        SettingsViewController * settings = [SettingsViewController new];
        settings.onDone = ^{
            [wself.navigationController pushViewController:matchmaking animated:YES];
        };
        UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:settings];
        [self.navigationController presentViewController:navigation animated:YES completion:nil];
    }
}

- (IBAction)didTapSettings:(id)sender {
    SettingsViewController * settings = [SettingsViewController new];
    UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:settings];
    settings.showBuildInfo = YES;
    settings.showFeedback = YES;
    settings.onDone = ^{};
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}

- (IBAction)didTapShare:(id)sender {
    [AnalyticsService event:@"ShareTap"];
    
    // Connect their facebook account first, then open the friend invite dialog
    // it doesn't make sense to invite friends without having them connect facebook first
    
    User * user = [UserService.shared currentUser];
    [UserFriendService.shared user:user authenticateFacebook:^(BOOL success, User * updated) {
        if (updated) {
            [UserService.shared saveCurrentUser];
        }
        
        if (success) {
            [UserFriendService.shared openFeedDialogTo:@[]];
        }
    }];
}


@end
