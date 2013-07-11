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
#import "PartiesViewController.h"
#import "MatchmakingViewController.h"
#import "UserService.h"
#import "LobbyService.h"
#import "AccountViewController.h"
#import "LocationService.h"
#import "ChallengeService.h"
#import "LobbyService.h"


@interface LandingViewController () <AccountFormDelegate>

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
    
    // Connect to user service right away!

    [UserService.shared connect];
    [LobbyService.shared connect];
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
    
    MatchViewController * match = [MatchViewController new];
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
    MatchmakingViewController * matchmaking = [MatchmakingViewController new];
    [self.navigationController pushViewController:matchmaking animated:YES];
}

- (IBAction)didTapSettings:(id)sender {
    AccountViewController * accounts = [AccountViewController new];
    accounts.delegate = self;
    [self.navigationController presentViewController:accounts animated:YES completion:nil];
}

- (void)didSubmitAccountForm:(NSString *)name {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
