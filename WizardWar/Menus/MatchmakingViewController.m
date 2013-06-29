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
#import "AccountViewController.h"
#import "LocationService.h"
#import "UserFriendService.h"
#import <ReactiveCocoa.h>

@interface MatchmakingViewController () <AccountFormDelegate>
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIView *accountView;

@property (nonatomic, readonly) NSArray * challenges;
@property (nonatomic, readonly) NSArray * users;

@property (nonatomic, strong) FirebaseConnection* connection;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *userLoginLabel;

@property (nonatomic, readonly) User * currentUser;
@property (strong, nonatomic) MatchLayer * match;

@end

@implementation MatchmakingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Matchmaking";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // CHECK AUTHENTICATED
    if ([UserService shared].isAuthenticated) {
        [self connect];
    }
    else {
        AccountViewController * accounts = [AccountViewController new];
        accounts.delegate = self;
        [self.navigationController presentViewController:accounts animated:YES completion:nil];
    }
}

- (void)connect {
    [LocationService.shared connect];
    [ChallengeService.shared connect];

    __weak MatchmakingViewController * wself = self;
    
    // LOBBY
    self.accountView.hidden = YES;
//    self.activityView.hidesWhenStopped = YES;
//    if (!LobbyService.shared.joined)
//        [self.activityView startAnimating];
//    self.userLoginLabel.text = self.currentUser.name;
//    [RACAble(LobbyService.shared, joined) subscribeNext:^(id x) {
//        [self.activityView stopAnimating];
//    }];
    
    [LobbyService.shared.updated subscribeNext:^(id x) {
        NSLog(@"UPDATED USERS");
        [wself.tableView reloadData];
    }];
    
    [RACAble(LocationService.shared, location) subscribeNext:^(id x) {
        [wself didUpdateLocation];
    }];
    [self didUpdateLocation];
    
    // CHALLENGES
    [ChallengeService.shared.updated subscribeNext:^(id x) {
        NSLog(@"UPDATED CHALLENGES");
        [wself.tableView reloadData];
    }];
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


#pragma mark - Location
-(void)didUpdateLocation {
    
    if (LocationService.shared.hasLocation) {
        self.currentUser.location = LocationService.shared.location;
    }
    
    if (LocationService.shared.hasLocation || LocationService.shared.denied) {
        [self joinLobby];
    }
}


#pragma mark - AccountFormDelegate
-(void)didCancelAccountForm {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)didSubmitAccountForm:(NSString *)name {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self connect];
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

- (NSArray*)friends {
    // Or filter it the other direction :)
    return [[UserFriendService.shared.friends.allValues filter:^BOOL(User * user) {
        return (LobbyService.shared.localUsers[user.userId] == nil);
    }] sortedArrayUsingComparator:^NSComparisonResult(User * user, User * buser) {
        if (user.friendCount > buser.friendCount) return NSOrderedAscending;
        else if (user.friendCount < buser.friendCount) return NSOrderedDescending;
        else return NSOrderedSame;
    }];
}


#pragma mark - Firebase stuff

- (void)joinLobby
{
    [LobbyService.shared joinLobby:self.currentUser location:LocationService.shared.location];
}

- (void)leaveLobby {
    [LobbyService.shared leaveLobby:self.currentUser];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.challenges count];
    } else if (section == 1){
        return [self.users count];
    } else {
        return [self.friends count];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == 0) return @"Challenges";
//    else if (section == 1) return @"Local Users";
//    else return @"Friends";
    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self tableView:tableView challengeCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        return [self tableView:tableView userCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 2) {
        return [self tableView:tableView friendCellForRowAtIndexPath:indexPath];
    } else {
        return nil;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView userCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.784 alpha:1.000];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.149 alpha:1.000];
    }
    
    User* user = self.users[indexPath.row];
    cell.textLabel.text = user.name;
    
    if ([LobbyService.shared userIsOnline:user])
        cell.textLabel.textColor = [UIColor greenColor];
    else
        cell.textLabel.textColor = [UIColor darkTextColor];
    
    CLLocationDistance distance = [LocationService.shared distanceFrom:user.location];
    cell.detailTextLabel.text = [LocationService.shared distanceString:distance];
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView friendCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.784 alpha:1.000];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.149 alpha:1.000];
    }
    
    User* user = self.friends[indexPath.row];
   
    if ([LobbyService.shared userIsOnline:user])
        cell.textLabel.textColor = [UIColor greenColor];
    else
        cell.textLabel.textColor = [UIColor darkTextColor];
    
    cell.textLabel.text = user.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i games played", user.friendCount];
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView challengeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InviteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.490 green:0.706 blue:0.275 alpha:1.000];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.149 alpha:1.000];        
    }
    
    Challenge * challenge = self.challenges[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ vs %@", [self nameOrYou:challenge.main.name], [self nameOrYou:challenge.opponent.name]];
    
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
    else if (indexPath.section == 1)
        [self didSelectUser:self.users[indexPath.row]];
    else
        [self didSelectFriend:self.friends[indexPath.row]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectUser:(User*)user {

    // Issue the challenge
    if ([LobbyService.shared userIsOnline:user]) {
        Challenge * challenge = [ChallengeService.shared user:self.currentUser challengeOpponent:user];
        [self joinMatch:challenge];
        [UserFriendService.shared user:UserService.shared.currentUser addChallenge:challenge];
    }
    
    // Or send a push notification
    else {
        NSLog(@"PUSH NOTIFICATION BABY");
    }
}

- (void)didSelectFriend:(User*)user {
    [self didSelectUser:user];
}

- (void)didSelectChallenge:(Challenge*)challenge {
    [self joinMatch:challenge];
}

- (void)joinMatch:(Challenge*)challenge {
    NSLog(@"JOIN THE READY SCREEN %@", challenge.matchId);    
    MatchViewController * match = [MatchViewController new];
    [match startChallenge:challenge currentWizard:UserService.shared.currentWizard];
    [self.navigationController presentViewController:match animated:YES completion:nil];
}

- (void)dealloc {
    // don't worry about disconnecting. If you aren't THERE, it's ok
}

@end
