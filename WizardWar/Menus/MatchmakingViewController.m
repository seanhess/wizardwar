//
//  MatchmakingViewController.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

// This is such a crappy way of doing all of this
// I need another approach.
// CoreData? -- would be a good idea

// How to do distance?
// Hmm..... Well, I have the location and userId of each one
// I just have to evaluate distance and keep track of ones that are close!

#import "MatchmakingViewController.h"
#import "WizardDirector.h"
#import "MatchLayer.h"
#import "Challenge.h"
#import "NSArray+Functional.h"
#import "FirebaseCollection.h"
#import "ConnectionService.h"
#import "MatchViewController.h"
#import "User.h"
#import "LobbyService.h"
#import "UserService.h"
#import "ChallengeService.h"
#import "AccountViewController.h"
#import "LocationService.h"
#import "UserFriendService.h"
#import <ReactiveCocoa.h>
#import "ComicZineDoubleLabel.h"
#import "ObjectStore.h"
#import "UserCell.h"
#import "ChallengeCell.h"

@interface MatchmakingViewController () <AccountFormDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIView *accountView;

@property (nonatomic, strong) ConnectionService* connection;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *userLoginLabel;

@property (nonatomic, readonly) User * currentUser;
@property (strong, nonatomic) MatchLayer * match;

@property (strong, nonatomic) NSFetchedResultsController * challengeResults;
@property (strong, nonatomic) NSFetchedResultsController * friendResults;
@property (strong, nonatomic) NSFetchedResultsController * localResults;
@property (strong, nonatomic) NSFetchedResultsController * allResults;

@end

@implementation MatchmakingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Custom Table Cells!
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ChallengeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ChallengeCell"];


    self.title = @"Matchmaking";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];
    
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
    NSError *error = nil;
    
    NSLog(@"MatchmakingViewController: connect");
    
    self.challengeResults = [ObjectStore.shared fetchedResultsForRequest:[ChallengeService.shared requestChallengesForUser:UserService.shared.currentUser]];
    self.challengeResults.delegate = self;
    [self.challengeResults performFetch:&error];
    
    self.friendResults = [ObjectStore.shared fetchedResultsForRequest:[UserService.shared requestFriends]];
    self.friendResults.delegate = self;
    [self.friendResults performFetch:&error];
    
    self.localResults = [ObjectStore.shared fetchedResultsForRequest:[LobbyService.shared requestCloseUsers]];
    self.localResults.delegate = self;
    [self.localResults performFetch:&error];
    
    // DEBUG ONLY: show all users. Uncomment and change # of sections to 4
    self.allResults = [ObjectStore.shared fetchedResultsForRequest:[UserService.shared requestAllUsersButMe]];
    self.allResults.delegate = self;
    [self.allResults performFetch:&error];
    

    // I think friends should be showing up faster, no?
    [self.tableView reloadData];
    
    [LocationService.shared connect];
    [ChallengeService.shared connectAndReset];

    __weak MatchmakingViewController * wself = self;

    // LOBBY
    self.accountView.hidden = YES;
    
    [RACAble(LocationService.shared, location) subscribeNext:^(id x) {
        [wself didUpdateLocation];
    }];
    [self didUpdateLocation];
    
    // CHALLENGES. join right away 
    [ChallengeService.shared.acceptedSignal subscribeNext:^(Challenge * challenge) {
        [wself joinMatch:challenge];
    }];
    

}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)disconnect {
//    [self leaveLobby];
//}
//
//- (void)reconnect {
//    [self joinLobby];
//}

#pragma mark NSFetchedResultsControllerDelegate methods


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSInteger sectionGlobal = 0;
    if (controller == self.challengeResults)
        sectionGlobal = 0;
    
    else if (controller == self.localResults) sectionGlobal = 1;
    else if (controller == self.friendResults) sectionGlobal = 2;
    else if (controller == self.allResults) sectionGlobal = 3;
    
    NSIndexPath * indexPathGlobal = [NSIndexPath indexPathForItem:indexPath.row inSection:sectionGlobal];
    NSIndexPath * newIndexPathGlobal = [NSIndexPath indexPathForItem:newIndexPath.row inSection:sectionGlobal];
    
    if (type == NSFetchedResultsChangeInsert) {
        if (sectionGlobal == 0) NSLog(@"CHALLENGE INSERT");
        [self.tableView insertRowsAtIndexPaths:@[newIndexPathGlobal] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        if (sectionGlobal == 0) NSLog(@"CHALLENGE DELETE");        
        [self.tableView deleteRowsAtIndexPaths:@[indexPathGlobal] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeMove) {
        if (sectionGlobal == 0) {
            NSLog(@"CHALLENGE MOVE");
            return;
        }
        
        // it already knows its user, just reload it
        UserCell * cell = (UserCell*)[self.tableView cellForRowAtIndexPath:indexPathGlobal];
        [cell reloadFromUser];
        [self.tableView moveRowAtIndexPath:indexPathGlobal toIndexPath:newIndexPathGlobal];
    }
    else if (type == NSFetchedResultsChangeUpdate) {
        if (sectionGlobal == 0) {
            NSLog(@"CHALLENGE UPDATE");
            // do a remove/insert instead. it's kewl looking
            [self.tableView deleteRowsAtIndexPaths:@[indexPathGlobal] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPathGlobal] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            UserCell * cell = (UserCell*)[self.tableView cellForRowAtIndexPath:indexPathGlobal];
            [cell reloadFromUser];
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
//    [self.tableView reloadData];
    [self.tableView endUpdates];
}



#pragma mark - Location
-(void)didUpdateLocation {
    
    if (LocationService.shared.hasLocation) {
        NSLog(@"MatchmakingViewController: hasLocation");
        CLLocation * location = LocationService.shared.location;
        self.currentUser.locationLongitude = location.coordinate.longitude;
        self.currentUser.locationLatitude = location.coordinate.latitude;
    }
    
    else {
        NSLog(@"MatchmakingViewController: NO LOCATION!");
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

- (User*)currentUser {
    return UserService.shared.currentUser;
}

#pragma mark - Challenges
-(void)checkAutoconnectChallenge:(Challenge*)challenge {
    if ([challenge.matchId isEqualToString:self.autoconnectToMatchId]) {
        [self joinMatch:challenge];
    }
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSIndexPath * localIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
        Challenge * challenge = [self.challengeResults objectAtIndexPath:localIndexPath];
        
        // If I created it, then delete it
        if ([ChallengeService.shared challenge:challenge isCreatedByUser:UserService.shared.currentUser]) {
            [ChallengeService.shared removeChallenge:challenge];
        }
        
        // otherwise decline it
        else {
            [ChallengeService.shared declineChallenge:challenge];
        }
        

    }
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Run Away!";
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [[self.challengeResults.sections objectAtIndex:0] numberOfObjects];
    } else if (section == 1){
        return [[self.localResults.sections objectAtIndex:0] numberOfObjects];
    } else if (section == 2) {
        return [[self.friendResults.sections objectAtIndex:0] numberOfObjects];
    } else if (section == 3) {
        return [[self.allResults.sections objectAtIndex:0] numberOfObjects];
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"Challenges";
    else if (section == 1) return @"Local Users (Online)";
    else if (section == 2) return @"Friends";
    else if (section == 3) return @"All Users (Debug)";
    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 0;
    else if (section == 1) return 0;
    else if (section == 2) return 0;
    else if (section == 3) return 26;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return 65;
    else return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self tableView:tableView challengeCellForRowAtIndexPath:indexPath];
    } else {
        User * user = [self userForIndexPath:indexPath];
        return [self tableView:tableView userCellForUser:user];
    }
}

-(User*)userForIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath * localIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    User * user = nil;
    if (indexPath.section == 1) {
        user = [self.localResults objectAtIndexPath:localIndexPath];
    } else if (indexPath.section == 2) {
        user = [self.friendResults objectAtIndexPath:localIndexPath];
    } else if (indexPath.section == 3) {
        user = [self.allResults objectAtIndexPath:localIndexPath];
    } 
    return user;
}

-(UITableViewCell*)tableView:(UITableView *)tableView userCellForUser:(User*)user {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    if (!cell) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UserCell"];
    }
    
    [cell setUser:user];

    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView challengeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChallengeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChallengeCell"];
    
    if (!cell) {
        cell = [[ChallengeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ChallengeCell"];
    }
    
    NSIndexPath * localIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    Challenge * challenge = [self.challengeResults objectAtIndexPath:localIndexPath];
    [cell setChallenge:challenge currentUser:UserService.shared.currentUser];
    
    return cell;    
}

- (NSString*)nameOrYou:(NSString*)name {
    if ([name isEqualToString:self.currentUser.name]) return @"You";
    else return name;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * localIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    if (indexPath.section == 0)
        [self didSelectChallenge:[self.challengeResults objectAtIndexPath:localIndexPath]];
    else if (indexPath.section == 1)
        [self didSelectUser:[self.localResults objectAtIndexPath:localIndexPath]];
    else if (indexPath.section == 2)
        [self didSelectUser:[self.friendResults objectAtIndexPath:localIndexPath]];
    else if (indexPath.section == 3)
        [self didSelectUser:[self.allResults objectAtIndexPath:localIndexPath]];
    
    else {}
        
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectUser:(User*)user {
    
    Challenge * existingChallenge = [ChallengeService.shared user:UserService.shared.currentUser challengedByOpponent:user];
    if (existingChallenge) {
        // accept their challenge instead
        [ChallengeService.shared acceptChallenge:existingChallenge];
    }
    
    else {
        // Issue the challenge
        [ChallengeService.shared user:self.currentUser challengeOpponent:user isRemote:!user.isOnline];
        
        // Do NOT join yet (wait until accepted)
    }
}

- (void)didSelectChallenge:(Challenge*)challenge {
    
    // If I have been challenged
    if ([challenge.opponent.userId isEqualToString:UserService.shared.currentUser.userId]) {
        [ChallengeService.shared acceptChallenge:challenge];
    }
}

- (void)joinMatch:(Challenge*)challenge {

    [ChallengeService.shared removeUserChallenge:UserService.shared.currentUser];
    [ChallengeService.shared declineAllChallenges:UserService.shared.currentUser];
    
    // Add as a friend
    [UserFriendService.shared user:UserService.shared.currentUser addChallenge:challenge];    
    
    MatchViewController * match = [MatchViewController new];
    [match startChallenge:challenge currentWizard:UserService.shared.currentWizard];
    [self.navigationController presentViewController:match animated:YES completion:nil];
}

- (void)dealloc {
    // don't worry about disconnecting. If you aren't THERE, it's ok
}

@end
