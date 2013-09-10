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
#import "HelpViewController.h"
#import "PreloadLayer.h"
#import "UIColor+Hex.h"
#import "MenuButton.h"
#import "ConnectionService.h"
#import "SpellbookViewController.h"
#import "InfoService.h"
#import "QuestViewController.h"
#import <ReactiveCocoa.h>
#import "User.h"
#import "QuestService.h"
#import "ProfileViewController.h"
#import <MessageUI/MessageUI.h>

#import <FacebookSDK/FacebookSDK.h>
#import "NSArray+Functional.h"

@interface LandingViewController ()  <FBFriendPickerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MenuButton *multiplayerButton;
@property (weak, nonatomic) IBOutlet MenuButton *questButton;
@property (nonatomic, strong) MatchViewController* match;
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
    
    self.view.backgroundColor = [UIColor colorFromRGB:0x404240];
    
    

    [UserFriendService.shared checkFBStatus:UserService.shared.currentUser];
    
    // just update the button once with the number of people online?
    // CHANGED: don't connect to the lobby yet. Gotta save the $$$
//    __weak LandingViewController * wself = self;
//    [RACAble(LobbyService.shared, totalInLobby) subscribeNext:^(id x) {
//        [wself renderTotalInLobby];
//    }];
//    [self renderTotalInLobby];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // DISCONNECT! all services
    [ConnectionService.shared disconnect];
    
    User * user = [UserService.shared currentUser];
    [self.questButton setTitle:[QuestService.shared questButtonName:user] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationPortrait)
        return YES;
    
    return NO;
}



//- (void)renderTotalInLobby {
//    NSString * title = nil;
//    if (LobbyService.shared.totalInLobby > 0)
//        title = [NSString stringWithFormat:@"(%i) Multiplayer", LobbyService.shared.totalInLobby];
//    else
//        title = @"Multiplayer";
//    [self.multiplayerButton setTitle:title forState:UIControlStateNormal];
//}

- (IBAction)didTapQuest:(id)sender {
    QuestViewController * quest = [QuestViewController new];
    [self.navigationController pushViewController:quest animated:YES];
    
//    PracticeModeAIService * ai = [PracticeModeAIService new];
//    MatchViewController * match = [[MatchViewController alloc] init];
//    [match createMatchWithWizard:UserService.shared.currentWizard withAI:ai];

//    self.match = match;
    
//    HelpViewController * help = [HelpViewController new];
//    help.delegate = self;
//    [match showHelp:help];
}

//- (void)didTapHelpClose:(HelpViewController *)help {
//    [self.match hideHelp:help];
//    [self.match startMatch];
//}



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
        ProfileViewController * profile = [ProfileViewController new];
        profile.onDone = ^{
            [wself.navigationController pushViewController:matchmaking animated:YES];
        };
        UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:profile];
        [self.navigationController presentViewController:navigation animated:YES completion:nil];
    }
}

- (IBAction)didTapSpellbook:(id)sender {
    SpellbookViewController * spellbook = [SpellbookViewController new];
    [self.navigationController pushViewController:spellbook animated:YES];
}

- (IBAction)didTapSettings:(id)sender {
    SettingsViewController * settings = [SettingsViewController new];
    UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:settings];
    settings.onDone = ^{};
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}

- (IBAction)didTapShare:(id)sender {
    [AnalyticsService event:@"share"];
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Share Wizard War" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Email", @"SMS", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) [self shareFacebook];
    else if (buttonIndex == 1) [self shareEmail];
    else if (buttonIndex == 2) [self shareSMS];
    return;
}

- (void)shareEmail {
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Cannot send email" message:@"Email is not enabled on your system" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [AnalyticsService event:@"share-email"];
    
    UserFriendService * service = [UserFriendService shared];
    MFMailComposeViewController *picker = [MFMailComposeViewController new];
    picker.mailComposeDelegate = self;
    [picker setSubject:service.inviteSubject];
    
    // Attach an image to the email
    // NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"jpg"];
    // NSData *myData = [NSData dataWithContentsOfFile:path];
    // [picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"rainy"];
    
    // Fill out the email body text
    NSString * body = [NSString stringWithFormat:@"%@\n\n%@", service.inviteBody, service.inviteLink];
    [picker setMessageBody:body isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)shareSMS {
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Cannot send text" message:@"Texting is not enabled on your system" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [AnalyticsService event:@"share-sms"];
    
    UserFriendService * service = [UserFriendService shared];
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    
    picker.body = [NSString stringWithFormat:@"%@\n\n%@", service.inviteBody, service.inviteLink];
    
    [self presentViewController:picker animated:YES completion:NULL];
}


- (void)shareFacebook {
    // Connect their facebook account first, then open the friend invite dialog
    // it doesn't make sense to invite friends without having them connect facebook first
    
    [AnalyticsService event:@"share-facebook"];
    
    
    User * user = [UserService.shared currentUser];
    [UserFriendService.shared user:user authenticateFacebook:^(BOOL success, User * updated) {
        if (updated) {
            [UserService.shared saveCurrentUser];
        }
        
        if (success) {
            [UserFriendService.shared openFeedDialogTo:@[] complete:^{
                [AnalyticsService event:@"share-facebook-complete"];
            } cancel:^{
                [AnalyticsService event:@"share-facebook-cancel"];
            }];
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (result == MFMailComposeResultSent)
        [AnalyticsService event:@"share-email-complete"];
    else
        [AnalyticsService event:@"share-email-cancel"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultSent)
        [AnalyticsService event:@"share-sms-complete"];
    else
        [AnalyticsService event:@"share-sms-cancel"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
