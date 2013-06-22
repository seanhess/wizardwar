//
//  MatchmakingViewController.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "MatchmakingViewController.h"
#import "WizardDirector.h"
#import "MatchLayer.h"
#import "Challenge.h"
#import "NSArray+Functional.h"
#import "FirebaseCollection.h"
#import "FirebaseConnection.h"
#import "MatchViewController.h"
#import "User.h"
#import "LobbyService.h"
#import "UserService.h"
#import "ChallengeService.h"
#import <ReactiveCocoa.h>

@interface MatchmakingViewController () 
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIImageView *splashView;
@property (weak, nonatomic) IBOutlet UILabel *splashLabel;

@property (nonatomic, readonly) NSArray * challenges;
@property (nonatomic, readonly) NSArray * users;

@property (nonatomic, strong) FirebaseConnection* connection;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *userLoginLabel;

@property (nonatomic, readonly) User * currentUser;
@property (strong, nonatomic) MatchLayer * match;
@end

@implementation MatchmakingViewController

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

    self.title = @"Matchmaking";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    __weak MatchmakingViewController * wself = self;
    
    // CHALLENGES
    [ChallengeService.shared connect];
    [ChallengeService.shared.updated subscribeNext:^(id x) {
        [wself.tableView reloadData];
    }];
    
    // LOBBY
    self.activityView.hidesWhenStopped = YES;
    if (!LobbyService.shared.joined)
        [self.activityView startAnimating];
    self.userLoginLabel.text = self.currentUser.name;
    [RACAble(LobbyService.shared, joined) subscribeNext:^(id x) {
        [self.activityView stopAnimating];
    }];

    [LobbyService.shared.updated subscribeNext:^(id x) {
        [wself.tableView reloadData];
    }];

    
    [self joinLobby];
}

- (void)viewDidAppear:(BOOL)animated {}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)disconnect {
    [self leaveLobby];
}

- (void)reconnect {
    [self joinLobby];
}

#pragma mark - Login

- (IBAction)didTapLogin:(id)sender {
    
}

- (NSArray*)challenges {
    return ChallengeService.shared.myChallenges.allValues;
}

- (NSArray*)users {
    return LobbyService.shared.localUsers.allValues;
}

- (User*)currentUser {
    return UserService.shared.currentUser;
}


#pragma mark - Firebase stuff

- (void)joinLobby
{
    [LobbyService.shared joinLobby:self.currentUser];
}

- (void)leaveLobby {
    [LobbyService.shared leaveLobby:self.currentUser];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.challenges count];
    } else if (section == 1){
        return [self.users count];
    } else {
        return 1; // practice game
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self tableView:tableView challengeCellForRowAtIndexPath:indexPath];
    } else {
        return [self tableView:tableView userCellForRowAtIndexPath:indexPath];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView userCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithWhite:0.784 alpha:1.000];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.149 alpha:1.000];
    }
    
    User* user = self.users[indexPath.row];
    cell.textLabel.text = user.name;
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView challengeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InviteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Challenge * challenge = self.challenges[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ vs %@", [self nameOrYou:challenge.main.name], [self nameOrYou:challenge.opponent.name]];
    cell.backgroundColor = [UIColor colorWithRed:0.490 green:0.706 blue:0.275 alpha:1.000];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.149 alpha:1.000];
    
    return cell;
}

- (NSString*)nameOrYou:(NSString*)name {
    if ([name isEqualToString:self.currentUser.name]) return @"You";
    else return name;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        [self didSelectChallenge:self.challenges[indexPath.row]];
    else
        [self didSelectUser:self.users[indexPath.row]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectUser:(User*)user {
    Challenge * challenge = [ChallengeService.shared user:self.currentUser challengeOpponent:user];
    
    MatchViewController * match = [MatchViewController new];
    [match startChallenge:challenge currentWizard:UserService.shared.currentWizard];
    [self.navigationController presentViewController:match animated:YES completion:nil];    
}

- (void)didSelectChallenge:(Challenge*)challenge {
    // Join the ready screen yo yo yo
    NSLog(@"JOIN THE READY SCREEN %@", challenge.matchId);
    
    MatchViewController * match = [MatchViewController new];
    [match startChallenge:challenge currentWizard:UserService.shared.currentWizard];
    [self.navigationController presentViewController:match animated:YES completion:nil];
    
}

- (void)dealloc {
    // don't worry about disconnecting. If you aren't THERE, it's ok
}

@end
