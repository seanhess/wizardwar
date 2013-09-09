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
#import "LocationService.h"
#import "UserFriendService.h"
#import <ReactiveCocoa.h>
#import "ComicZineDoubleLabel.h"
#import "ObjectStore.h"
#import "UserCell.h"
#import "ChallengeCell.h"
#import "FriendsViewController.h"
#import <BButton.h>
#import "ProfileViewController.h"
#import <NSString+FontAwesome.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AnalyticsService.h"
#import "UIViewController+Idiom.h"
#import "InfoService.h"
#import "WarningCell.h"
#import "ProfileCell.h"
#import "AppStyle.h"
#import <MessageUI/MessageUI.h>

#define ROW_STATS 0
#define ROW_WARNING 1

#define SECTION_INDEX_WARNINGS 0
#define SECTION_INDEX_CHALLENGES 1

// People who are "Right here" but who aren't friends. Usually this will be blank
#define SECTION_INDEX_LOCAL 2

// Friends who are online
#define SECTION_INDEX_FRIENDS_ONLINE 3

// People who are closeby, but not RIGHT here
#define SECTION_INDEX_CLOSE 4
#define SECTION_INDEX_RECENT 5

// Offline friends
#define SECTION_INDEX_FRIENDS 6

#define SECTION_INDEX_STRANGERS 7

#define SECTION_INDEX_ONLINE_USERS SECTION_INDEX_LOCAL
#define SECTION_INDEX_OFFLINE_USERS SECTION_INDEX_FRIENDS
#define SECTION_INDEX_LAST SECTION_INDEX_FRIENDS

// Do one warning at a time?

@interface MatchmakingViewController () <NSFetchedResultsControllerDelegate, FBFriendPickerDelegate, MatchViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView * tableView;

@property (nonatomic, strong) ConnectionService* connection;

@property (nonatomic, readonly) User * currentUser;
@property (strong, nonatomic) MatchLayer * match;

@property (strong, nonatomic) NSFetchedResultsController * challengeResults;
@property (strong, nonatomic) NSFetchedResultsController * friendResults;
@property (strong, nonatomic) NSFetchedResultsController * localResults;
@property (strong, nonatomic) NSFetchedResultsController * otherCloseResults;
@property (strong, nonatomic) NSFetchedResultsController * recentResults;
@property (strong, nonatomic) NSFetchedResultsController * friendOnlineResults;
@property (strong, nonatomic) NSFetchedResultsController * allResults;

@property (strong, nonatomic) RACDisposable * matchStatusSignal;

@property (strong, nonatomic) IBOutlet UITextView *explanationsView;

@property (weak, nonatomic) IBOutlet UIView *loadingOverlayView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet BButton *inviteFriendsButton;

@property (strong, nonatomic) MatchViewController * currentMatch;
@property (strong, nonatomic) Challenge * currentChallenge;

@property (strong, nonatomic) NSString * locationWarning;
@property (strong, nonatomic) NSString * pushWarning;

@property (nonatomic) BOOL connectedToLobby;

@end

@implementation MatchmakingViewController

- (void)viewDidLoad
{
    [AnalyticsService event:@"multiplayer"];
    
    [super viewDidLoad];

//    [self.inviteFriendsButton addAwesomeIcon:FAIconExternalLink beforeTitle:YES];
//    [self.inviteFriendsButton addAwesomeIcon:FAIconEnvelope beforeTitle:YES];
    [self.inviteFriendsButton addAwesomeIcon:FAIconGroup beforeTitle:YES];
    [self.inviteFriendsButton setType:BButtonTypePrimary];
//    self.inviteFriendsButton.color = [AppStyle blueNavColor];
//    [self.inviteFriendsButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:26];

//    NSString * buttonText = [NSString stringFromAwesomeIcon:FAIconUser];
//    UIBarButtonItem *accountButton = [[UIBarButtonItem alloc] initWithTitle:buttonText style:UIBarButtonItemStylePlain target:self action:@selector(didTapAccount)];
//    [accountButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FontAwesome" size:20.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
//    self.navigationItem.rightBarButtonItem = accountButton;
    
    // Custom Table Cells!
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ChallengeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ChallengeCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WarningCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"WarningCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:[ProfileCell identifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[ProfileCell identifier]];
    
    
    [self.tableView setTableFooterView:self.explanationsView];
    
    self.title = @"Matchmaking";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];

    __weak MatchmakingViewController * wself = self;
    
    // LOBBY
    [RACAbleWithStart(LobbyService.shared, joined) subscribeNext:^(id x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself didUpdateJoinedLobby:LobbyService.shared.joined];
        });
    }];    
    
    [RACAble(LocationService.shared, accepted) subscribeNext:^(id x) {
        [wself setWarnings];
//        [wself.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_INDEX_WARNINGS] withRowAnimation:UITableViewRowAnimationAutomatic];
        // need to display a different set of sections
        [wself.tableView reloadData];
    }];
    
    [RACAble(UserService.shared, pushAccepted) subscribeNext:^(id x) {
        [wself setWarnings];
        [wself.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_INDEX_WARNINGS] withRowAnimation:UITableViewRowAnimationAutomatic];        
    }];
    
    [wself setWarnings];    
    
    
    // CHECK AUTHENTICATED
//    if ([UserService shared].isAuthenticated) {
        [self connect];
//    }
//    else {
//        AccountViewController * accounts = [AccountViewController new];
//        accounts.delegate = self;
//        [self.navigationController presentViewController:accounts animated:YES completion:nil];
//    }
}

- (void)setWarnings {
    if ([self shouldShowLocationWarning]) {
        self.locationWarning = @"Enable Location Services to see players near you:\n\n    Settings / Privacy / Location Services";
        if (LocationService.shared.cannotFindLocation) {
            self.locationWarning = [NSString stringWithFormat:@"Location Error: %@", self.locationWarning];
        }
    }
    
    if ([self shouldShowPushWarning]) {
        self.pushWarning = @"Enable Push Notifications so friends can invite you to play while you are offline:\n\n    Settings / Notifications";
    }    
}

- (BOOL)shouldShowLocationWarning {
    return !LocationService.shared.accepted;
}

- (BOOL)shouldShowPushWarning {
    return !UserService.shared.pushAccepted;
}

- (void)connect {
    NSError *error = nil;
    
    // Connect to services
    Firebase * rootRef = [[Firebase alloc] initWithUrl:InfoService.firebaseUrl];

    [ConnectionService.shared monitorDomain:rootRef];
    [UserService.shared connect:rootRef];
    [LobbyService.shared connect:rootRef];
    [LocationService.shared connect];
    
    [ChallengeService.shared connectAndReset:self rootRef:rootRef];
    [LocationService.shared startMonitoring];
    
    User * user = [UserService.shared currentUser];
    NSLog(@"MatchmakingViewController: connect");
    
    NSLog(@" - challengeResults");
    self.challengeResults = [ObjectStore.shared fetchedResultsForRequest:[ChallengeService.shared requestChallengesForUser:self.currentUser]];
    self.challengeResults.delegate = self;
    [self.challengeResults performFetch:&error];

    NSLog(@" - friendResults");
    self.friendResults = [ObjectStore.shared fetchedResultsForRequest:[UserFriendService.shared requestFriends:user isOnline:NO]];
    self.friendResults.delegate = self;
    [self.friendResults performFetch:&error];

    NSLog(@" - friendOnlineResults");
    self.friendOnlineResults = [ObjectStore.shared fetchedResultsForRequest:[UserFriendService.shared requestFriends:user isOnline:YES]];
    self.friendOnlineResults.delegate = self;
    [self.friendOnlineResults performFetch:&error];
   
    NSLog(@" - localResults");
    // Show anyone right here, and 4 closest other users online
    self.localResults = [ObjectStore.shared fetchedResultsForRequest:[LobbyService.shared requestCloseUsers:self.currentUser]];
    self.localResults.delegate = self;
    [self.localResults performFetch:&error];
    
    NSLog(@" - otherCloseResults");    
    self.otherCloseResults = [ObjectStore.shared fetchedResultsForRequest:[LobbyService.shared requestClosestUsers:self.currentUser withLimit:4]];
    self.otherCloseResults.delegate = self;
    [self.otherCloseResults performFetch:&error];
    
    self.recentResults = [ObjectStore.shared fetchedResultsForRequest:[LobbyService.shared requestRecentUsers:self.currentUser withLimit:4]];
    self.recentResults.delegate = self;
    [self.recentResults performFetch:&error];
    
    // DEBUG ONLY: show all users. Uncomment and change # of sections to 4
//    self.allResults = [ObjectStore.shared fetchedResultsForRequest:[UserFriendService.shared requestStrangers:user withLimit:5]];
//    self.allResults.delegate = self;
//    [self.allResults performFetch:&error];
    

    // I think friends should be showing up faster, no?
    [self.tableView reloadData];
    

//    __weak MatchmakingViewController * wself = self;

    
    // Join the lobby!
    [LobbyService.shared joinLobby:self.currentUser];
}

- (void)viewWillAppear:(BOOL)animated {
    self.currentChallenge = nil;
    self.currentMatch = nil;
    if (ChallengeService.shared.connected) {
        [ChallengeService.shared removeUserChallenge:self.currentUser];
        // Why do this? to remove the challenge you were just in.
        // If the other user leaves
        //[ChallengeService.shared declineAllChallenges:self.currentUser];
        // when the invitee hits back, it's still here for him.
        // need to remove the one I was just in. 
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_INDEX_WARNINGS] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)viewWillDisappear:(BOOL)animated {
    // don't want to disconnect here, really, it's when I'm about to get popped all the way off
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark NSFetchedResultsControllerDelegate methods


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSInteger sectionGlobal = 0;
    if (controller == self.challengeResults) sectionGlobal = SECTION_INDEX_CHALLENGES;
    else if (controller == self.localResults) sectionGlobal = SECTION_INDEX_LOCAL;
    else if (controller == self.otherCloseResults) sectionGlobal = SECTION_INDEX_CLOSE;
    else if (controller == self.recentResults) sectionGlobal = SECTION_INDEX_RECENT;
    else if (controller == self.friendResults) sectionGlobal = SECTION_INDEX_FRIENDS;
    else if (controller == self.allResults) sectionGlobal = SECTION_INDEX_STRANGERS;
    else if (controller == self.friendOnlineResults) sectionGlobal = SECTION_INDEX_FRIENDS_ONLINE;
    
    if (sectionGlobal == SECTION_INDEX_RECENT && ![self shouldShowRecent]) return;
    else if (sectionGlobal == SECTION_INDEX_CLOSE && ![self shouldShowOtherClose]) return;
    
    NSIndexPath * indexPathGlobal = [NSIndexPath indexPathForItem:indexPath.row inSection:sectionGlobal];
    NSIndexPath * newIndexPathGlobal = [NSIndexPath indexPathForItem:newIndexPath.row inSection:sectionGlobal];
    
    if (type == NSFetchedResultsChangeInsert) {
        if (sectionGlobal == SECTION_INDEX_CHALLENGES) NSLog(@"CHALLENGE INSERT");
        [self.tableView insertRowsAtIndexPaths:@[newIndexPathGlobal] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        if (sectionGlobal == SECTION_INDEX_CHALLENGES) NSLog(@"CHALLENGE DELETE");        
        [self.tableView deleteRowsAtIndexPaths:@[indexPathGlobal] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeMove) {
        if (sectionGlobal == SECTION_INDEX_CHALLENGES) {
            NSLog(@"CHALLENGE MOVE");
            return;
        }
        
        // it already knows its user, just reload it
        UserCell * cell = (UserCell*)[self.tableView cellForRowAtIndexPath:indexPathGlobal];
        [cell reloadFromUser];
        [self.tableView moveRowAtIndexPath:indexPathGlobal toIndexPath:newIndexPathGlobal];
    }
    else if (type == NSFetchedResultsChangeUpdate) {
        if (sectionGlobal == SECTION_INDEX_CHALLENGES) {
            NSLog(@"CHALLENGE UPDATE");

            // do a remove/insert instead. it's kewl looking
            [self.tableView deleteRowsAtIndexPaths:@[indexPathGlobal] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPathGlobal] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            Challenge * challenge = [self.challengeResults objectAtIndexPath:indexPath];
            if (challenge.status == ChallengeStatusAccepted) {
                [self joinMatch:challenge];
            }

        }
        else {
            UserCell * cell = (UserCell*)[self.tableView cellForRowAtIndexPath:indexPathGlobal];
            [cell reloadFromUser];
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (BOOL)shouldShowRecent {
    return !self.shouldShowOtherClose;
}

- (BOOL)shouldShowOtherClose {
    return LocationService.shared.accepted;
}


#pragma mark - Lobby {
-(void)didUpdateJoinedLobby:(BOOL)joined {
    
    if (joined) {
        [self hideLoading];
    }

    else {
        [ChallengeService.shared removeUserChallenge:self.currentUser];

        // If we DISCONNECT, decline all challenges
        // but when you load this for the first, you START disconnected.
        if (self.connectedToLobby == YES)
            [ChallengeService.shared declineAllChallenges:self.currentUser];
        
        [self showLoading];
    }
    
    self.connectedToLobby = joined;
}

-(void)showLoading {
    [self.activityView startAnimating];
    [UIView animateWithDuration:0.2 animations:^{
        self.loadingOverlayView.alpha = 1.0;
    }];    
}

-(void)hideLoading {
    [self.activityView stopAnimating];
    [UIView animateWithDuration:0.2 animations:^{
        self.loadingOverlayView.alpha = 0.0;
    }];
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



#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_INDEX_CHALLENGES) return YES;
    if (indexPath.section == SECTION_INDEX_FRIENDS) return YES;
    if (indexPath.section == SECTION_INDEX_FRIENDS_ONLINE) return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSIndexPath * localIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
        
        if (indexPath.section == SECTION_INDEX_CHALLENGES) {
            Challenge * challenge = [self.challengeResults objectAtIndexPath:localIndexPath];
            
            // If I created it, then delete it
            if ([ChallengeService.shared challenge:challenge isCreatedByUser:self.currentUser]) {
                [ChallengeService.shared removeChallenge:challenge];
            }
            
            // otherwise decline it
            else {
                [ChallengeService.shared declineChallenge:challenge];
            }            
        } else {
            User * user = [self userForIndexPath:indexPath];
            [UserFriendService.shared user:self.currentUser removeFrenemy:user];
        }
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_INDEX_CHALLENGES)
        return @"Run Away!";
    return @"Defrenemy";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_INDEX_LAST+1;
//    return 5; // to show debug users
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_INDEX_CHALLENGES) {
        return [[self.challengeResults.sections objectAtIndex:0] numberOfObjects];
    } else if (section == SECTION_INDEX_LOCAL) {
        return [[self.localResults.sections objectAtIndex:0] numberOfObjects];
    } else if (section == SECTION_INDEX_CLOSE) {
        if (!LocationService.shared.accepted) return 0;
        return [[self.otherCloseResults.sections objectAtIndex:0] numberOfObjects];
    } else if (section == SECTION_INDEX_RECENT) {
        if (LocationService.shared.accepted) return 0;
        return [[self.recentResults.sections objectAtIndex:0] numberOfObjects];
    } else if (section == SECTION_INDEX_FRIENDS) {
        return [[self.friendResults.sections objectAtIndex:0] numberOfObjects];
    } else if (section == SECTION_INDEX_FRIENDS_ONLINE) {
        return [[self.friendOnlineResults.sections objectAtIndex:0] numberOfObjects];
    } else if (section == SECTION_INDEX_STRANGERS) {
        return [[self.allResults.sections objectAtIndex:0] numberOfObjects];
    } else if (section == SECTION_INDEX_WARNINGS) {
        if ([self shouldShowLocationWarning] || [self shouldShowPushWarning])
            return 2;
        else
            return 1;
    } else {
        return 0;
    }
}


//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return self.explanationsView.frame.size.height + 30;
//}

//-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    if (section == SECTION_INDEX_LAST) {
//        return self.explanationsView;
//    }
//    return nil;
//}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTION_INDEX_CHALLENGES) return @"Challenges";
    
    else if (section == SECTION_INDEX_ONLINE_USERS) return @"Online";
    else if (section == SECTION_INDEX_OFFLINE_USERS) return @"Friends Offline";

    else if (section == SECTION_INDEX_RECENT) return @"Recent";
    else if (section == SECTION_INDEX_CLOSE) return @"Nearby";
    else if (section == SECTION_INDEX_LOCAL) return @"Right Here";
    else if (section == SECTION_INDEX_FRIENDS) return @"Frenemies";
    else if (section == SECTION_INDEX_FRIENDS_ONLINE) return @"Friends Online";
    else if (section == SECTION_INDEX_STRANGERS) return @"Strangers";
    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == SECTION_INDEX_MESSAGES && (!LocationService.shared.accepted || !UserService.shared.pushAccepted))
//        return self.warningsView.frame.size.height;
//    else if (section == SECTION_INDEX_ONLINE_USERS) return 26;
//    else if (section == SECTION_INDEX_OFFLINE_USERS) return 26;
//    else if (section == 1) return 26;
//    else if (section == 2) return 0;
//    else if (section == 3) return 26;
//    else if (section == 4) return 26;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_INDEX_CHALLENGES) return 65;
    if (indexPath.section == SECTION_INDEX_WARNINGS && indexPath.row == ROW_WARNING) return 90;
    else return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_INDEX_CHALLENGES) {
        return [self tableView:tableView challengeCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == SECTION_INDEX_WARNINGS) {
        return [self tableView:tableView warningCellForRowAtIndexPath:indexPath];
    } else {
        User * user = [self userForIndexPath:indexPath];
        return [self tableView:tableView userCellForUser:user];
    }
}

-(User*)userForIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath * localIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    User * user = nil;
    if (indexPath.section == SECTION_INDEX_LOCAL) {
        user = [self.localResults objectAtIndexPath:localIndexPath];
    } else if (indexPath.section == SECTION_INDEX_CLOSE) {
        user = [self.otherCloseResults objectAtIndexPath:localIndexPath];
    } else if (indexPath.section == SECTION_INDEX_RECENT) {
        user = [self.recentResults objectAtIndexPath:localIndexPath];
    } else if (indexPath.section == SECTION_INDEX_FRIENDS) {
        user = [self.friendResults objectAtIndexPath:localIndexPath];
    } else if (indexPath.section == SECTION_INDEX_FRIENDS_ONLINE) {
        user = [self.friendOnlineResults objectAtIndexPath:localIndexPath];
    } else if (indexPath.section == SECTION_INDEX_STRANGERS) {
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
    [cell setChallenge:challenge currentUser:self.currentUser];
    
    return cell;    
}

-(UITableViewCell*)tableView:(UITableView *)tableView warningCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == ROW_WARNING) {
        WarningCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WarningCell"];
        if ([self shouldShowLocationWarning])
            [cell setWarningText:self.locationWarning];
        else
            [cell setWarningText:self.pushWarning];
        return cell;
    }
    
    else {
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:[ProfileCell identifier]];
        User * user = [UserService.shared currentUser];
        [cell setUser:user];
        return cell;
    }
}


- (NSString*)nameOrYou:(NSString*)name {
    if ([name isEqualToString:self.currentUser.name]) return @"You";
    else return name;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * localIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    if (indexPath.section == SECTION_INDEX_CHALLENGES)
        [self didSelectChallenge:[self.challengeResults objectAtIndexPath:localIndexPath]];
    else if (indexPath.section == SECTION_INDEX_LOCAL)
        [self didSelectUser:[self.localResults objectAtIndexPath:localIndexPath]];
    else if (indexPath.section == SECTION_INDEX_CLOSE)
        [self didSelectUser:[self.otherCloseResults objectAtIndexPath:localIndexPath]];
    else if (indexPath.section == SECTION_INDEX_RECENT)
        [self didSelectUser:[self.recentResults objectAtIndexPath:localIndexPath]];
    else if (indexPath.section == SECTION_INDEX_FRIENDS)
        [self didSelectUser:[self.friendResults objectAtIndexPath:localIndexPath]];
    else if (indexPath.section == SECTION_INDEX_FRIENDS_ONLINE)
        [self didSelectUser:[self.friendOnlineResults objectAtIndexPath:localIndexPath]];
    else if (indexPath.section == SECTION_INDEX_STRANGERS)
        [self didSelectUser:[self.allResults objectAtIndexPath:localIndexPath]];
    else if (indexPath.section == SECTION_INDEX_WARNINGS && indexPath.row == ROW_STATS)
        [self didTapAccount];
    
    else {}
        
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectUser:(User*)user {
    
    if ([UserService.shared user:self.currentUser shouldUpgradeToMatch:user]) {
        return [self forceUpgradeToMatch:user];
    }
    
    Challenge * existingChallenge = [ChallengeService.shared user:self.currentUser challengedByOpponent:user];
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
    if ([challenge.opponent.userId isEqualToString:self.currentUser.userId]) {

        if ([UserService.shared user:self.currentUser shouldUpgradeToMatch:challenge.main]) {
            return [self forceUpgradeToMatch:challenge.main];
        }
                
        [ChallengeService.shared acceptChallenge:challenge];
    }
}

- (void)joinMatch:(Challenge*)challenge {
    
    // the challenge is updated, and bindings are fired, BEFORE I get to the end of this block
    // Therefore: make EXTRA SURE you can't join a match while it's going, or you end up joining the same one twice
    
    if (self.currentMatch) return;
    NSLog(@"---- JOIN MATCH (%@) ----", challenge.matchId);
    self.currentChallenge = challenge;
    self.currentMatch = [[MatchViewController alloc] init];
    self.currentMatch.delegate = self;
    [self.currentMatch createMatchWithChallenge:challenge currentWizard:UserService.shared.currentWizard];
    [self.navigationController presentViewController:self.currentMatch animated:YES completion:nil];
    
    // Should be called after viewDidLoad
    [self.currentMatch startMatch];

    // Only the active user broadcasts what he is doing
    [LobbyService.shared user:self.currentUser joinedMatch:challenge.matchId];
}

- (NSArray*)didFinishChallenge:(Challenge *)challenge didWin:(BOOL)didWin {
    return [UserFriendService.shared user:self.currentUser addChallenge:challenge didWin:didWin];
}

- (void)dealloc {
    [ChallengeService.shared disconnect];
    // don't worry about disconnecting. If you aren't THERE, it's ok
    NSLog(@"MatchmakingViewController: dealloc");
}

- (void)forceUpgradeToMatch:(User*)user {
    NSString * message = [NSString stringWithFormat:@"'%@' has a newer version of Wizard War (%@). Download it now?", user.name, user.version];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Upgrade?" message:message delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Upgrade", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[InfoService downloadUrl]]];
    }
}


# pragma mark - Buttons n stuff
- (IBAction)didTapInviteFriends:(id)sender {
    
    // 1. need to choose between email, sms, or facebook
    // 2. 
    
    [AnalyticsService event:@"invite"];
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Invite Frenemies" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Email", @"SMS", nil];
    [sheet showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) [self inviteFacebookFriend];
    else if (buttonIndex == 1) [self inviteEmail];
    else if (buttonIndex == 2) [self inviteSMS];
    return;
}

- (void)inviteEmail {
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Cannot send email" message:@"Email is not enabled on your system" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [AnalyticsService event:@"invite-email"];    
    
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

- (void)inviteSMS {
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Cannot send text" message:@"Texting is not enabled on your system" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [AnalyticsService event:@"invite-sms"];
    
    UserFriendService * service = [UserFriendService shared];
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    
    picker.body = [NSString stringWithFormat:@"%@\n\n%@", service.inviteBody, service.inviteLink];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)inviteFacebookFriend {
    // Connect their facebook account first, then open the friend invite dialog
    // it doesn't make sense to invite friends without having them connect facebook first
    
    [AnalyticsService event:@"invite-facebook"];    
    
    User * user = [UserService.shared currentUser];
    [self showLoading];
    [UserFriendService.shared user:user authenticateFacebook:^(BOOL success, User * updated) {
        [self hideLoading];
        if (updated) {
            [UserService.shared saveCurrentUser];
        }
        
        if (success) {
            [self openFriendPickerThenInviteSingleFriend];
        }
    }];
}

- (void)openFriendPickerThenInviteSingleFriend {
    FBFriendPickerViewController * friends = [[FBFriendPickerViewController alloc] init];
    friends.title = @"Choose a Friend";
    friends.delegate = self;
    friends.allowsMultipleSelection = NO;
    friends.doneButton = nil;
    
    [friends loadData];
    [friends clearSelection];
    
    [self.navigationController presentViewController:friends animated:YES completion:nil];
}

- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
    [self facebookViewControllerDoneWasPressed:friendPicker];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    [AnalyticsService event:@"invite-facebook-friend"];
    
    FBFriendPickerViewController *friendPickerController = (FBFriendPickerViewController*)sender;
    NSLog(@"Selected friends: %@", friendPickerController.selection);
    // Dismiss the friend picker
//    [[sender presentingViewController] dismissModalViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    NSArray * friendIds = [friendPickerController.selection map:^(NSDictionary*info) {
        return info[@"id"];
    }];
    
    [UserFriendService.shared openFeedDialogTo:friendIds complete:^{
        [AnalyticsService event:@"invite-facebook-friend-complete"];
    } cancel:^{
        [AnalyticsService event:@"invite-facebook-friend-cancel"];
    }];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    NSLog(@"Canceled");
    [AnalyticsService event:@"invite-facebook-cancel"];
    // Dismiss the friend picker
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapAccount {
    ProfileViewController * profile = [ProfileViewController new];
    UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:profile];
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}

#pragma mark - Mail Composer
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (result == MFMailComposeResultSent)
        [AnalyticsService event:@"invite-email-complete"];
    else
        [AnalyticsService event:@"invite-email-cancel"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultSent)
        [AnalyticsService event:@"invite-sms-complete"];
    else
        [AnalyticsService event:@"invite-sms-cancel"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
