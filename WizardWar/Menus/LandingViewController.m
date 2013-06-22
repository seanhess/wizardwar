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

@interface LandingViewController ()

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

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [UserService.shared connect];
    [LobbyService.shared connect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapQuest:(id)sender {
    Wizard * guest = [Wizard new];
    guest.name = @"guest";
//    guest.wizardType = [Wizard randomWizardType];
    guest.wizardType = WIZARD_TYPE_ONE;
    
    Wizard * ai = [Wizard new];
    ai.name = @"zai";
    ai.wizardType = WIZARD_TYPE_ONE;
    
    MatchViewController * match = [MatchViewController new];
    [match connectToMatchWithId:@"Practice" currentPlayer:guest withAI:ai];
    match.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
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
    MatchmakingViewController * matchMaking = [MatchmakingViewController new];
    [self.navigationController pushViewController:matchMaking animated:YES];
}

@end
