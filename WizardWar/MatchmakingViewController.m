//
//  MatchmakingViewController.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "MatchmakingViewController.h"
#import "WWDirector.h"
#import "CCScene+Layers.h"
#import "MatchLayer.h"
#import "User.h"
#import "Invite.h"
#import "NSArray+Functional.h"

@interface MatchmakingViewController () <MatchLayerDelegate>
@property (nonatomic, strong) CCDirectorIOS * director;
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

-(void)loadView {
    [super loadView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Matchmaking";
    self.view.backgroundColor = [UIColor redColor];
    
    // init and style the lobby/invites table view
    self.matchesTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.matchesTableViewController.tableView.backgroundView = [[UIView alloc] init];
    self.matchesTableViewController.tableView.backgroundView.backgroundColor = [UIColor colorWithWhite:0.149 alpha:1.000];
    [self.matchesTableViewController.tableView setSeparatorColor:[UIColor clearColor]];
    [self.matchesTableViewController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.matchesTableViewController.tableView.delegate = self;
    self.matchesTableViewController.tableView.dataSource = self;
    [self.view addSubview:self.matchesTableViewController.view];
    
    [self.view layoutIfNeeded];
    
    self.users = [[NSMutableArray alloc] init];
    self.invites = [[NSMutableArray alloc] init];
    [self loadDataFromFirebase];
    
    // check for set nickname
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.nickname = [defaults stringForKey:@"nickname"];
    if (self.nickname == nil) {
        // nickname not set yet so prompt for it
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Nickname" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [av show];
        av.delegate = self;
    } else {
        [self addToLobbyList];
    }
    
    // secret button to play agains nobody
//    UIButton *secretButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    secretButton.frame = CGRectMake(self.view.bounds.size.height-22, self.view.bounds.size.width-22, 22, 22);
//    [secretButton addTarget:self action:@selector(didTapSecretButton:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:secretButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didTapSecretButton:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Invite * invite = [Invite new];
        invite.invitee = @"Charlie";
        invite.inviter = @"Bad guy";
        invite.matchID = [NSString stringWithFormat:@"%i", arc4random()];
        [self joinMatch:invite playerName:@"Charlie"];
    });
}

- (void)joinMatch:(Invite*)invite playerName:(NSString *)playerName {
    [self startGameWithMatchId:invite.matchID player:self.currentPlayer withAI:nil];
    [self removeInvite:invite];
}

- (Player*)currentPlayer {
    Player * player = [Player new];
    player.name = self.nickname;
    return player;
}

- (void)startGameWithMatchId:(NSString*)matchId player:(Player*)player withAI:(Player*)ai {
    if (self.isInMatch) return;
    self.isInMatch = YES;
    NSAssert(matchId, @"No match id!");
    NSLog(@"joining match %@ with %@", matchId, player.name);
    
    if (!self.director) {
        self.director = [WWDirector directorWithBounds:self.view.bounds];
    }
    
    MatchLayer * match = [[MatchLayer alloc] initWithMatchId:matchId player:player withAI:ai];
    match.delegate = self;
    
    if (self.director.runningScene) {
        [self.director replaceScene:[CCScene sceneWithLayer:match]];
    }
    else {
        [self.director runWithScene:[CCScene sceneWithLayer:match]];
    }
    
    [self.navigationController pushViewController:self.director animated:YES];
}

- (void)doneWithMatch {
    self.isInMatch = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.nickname = [alertView textFieldAtIndex:0].text;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.nickname forKey:@"nickname"];
    [self addToLobbyList];
}

#pragma mark - Firebase stuff

- (void)loadDataFromFirebase
{
    self.firebaseLobby = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/lobby"];
    
    self.firebaseInvites = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/invites"];
    
    self.firebaseMatches = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseio.com/match"];
    
    // LOBBY
    [self.firebaseLobby observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        User * user = [User new];
        [user setValuesForKeysWithDictionary:snapshot.value];
        // we don't want to show us in the list
        if (user.name != self.nickname) {
            [self.users addObject:user];
            [self.matchesTableViewController.tableView reloadData];
        }
    }];
    
    [self.firebaseLobby observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        User * removedUser = [User new];
        [removedUser setValuesForKeysWithDictionary:snapshot.value];
        self.users = [[self.users filter:^BOOL(User * user) {
            return ![user.name isEqualToString:removedUser.name];
        }] mutableCopy];
        [self.matchesTableViewController.tableView reloadData];
    }];
    
    
    //INVITES
    [self.firebaseInvites observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        Invite * invite = [Invite new];
        [invite setValuesForKeysWithDictionary:snapshot.value];
        // only show invites that apply to you
        if ([invite.invitee isEqualToString:self.nickname] || [invite.inviter isEqualToString:self.nickname ]) {
            [self.invites addObject:invite];
            [self.matchesTableViewController.tableView reloadData];
        }
    }];
    
    [self.firebaseInvites observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        Invite * removedInvite = [Invite new];
        [removedInvite setValuesForKeysWithDictionary:snapshot.value];
        [self removeInvite:removedInvite];
    }];
    
}

-(void)removeInvite:(Invite*)removedInvite {
    self.invites = [[self.invites filter:^BOOL(Invite * invite) {
        return ![invite.inviteId isEqualToString:removedInvite.inviteId];
    }] mutableCopy];
    [self.matchesTableViewController.tableView reloadData];
}

- (void)addToLobbyList
{
    User * user = [User new];
    user.name = self.nickname;
    Firebase * userNode = [self.firebaseLobby childByAppendingPath:self.nickname];
    [userNode setValue:user.toObject];
    [userNode onDisconnectRemoveValue];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.invites count] + 1;
    } else {
        return [self.users count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    if (section == 0) {
        UIImage *image = [UIImage imageNamed:@"navbar-logo.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        CGRect frame = imageView.frame;
        frame.origin.y = 10;
        imageView.frame = frame;
        [view addSubview:imageView];
    } else {
        UIImage *image = [UIImage imageNamed:@"wizard-lobby.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGRect size = self.view.bounds;
        imageView.frame = CGRectMake(((size.size.width - 159)/ 2),20,159,20);
        [view addSubview:imageView];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self tableView:tableView inviteCellForRowAtIndexPath:indexPath];
    } else {
        return [self tableView:tableView userCellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 60;
    } else {
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView userCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithWhite:0.784 alpha:1.000];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.149 alpha:1.000];
    }
    
    User* user = [self.users objectAtIndex:indexPath.row];
    
    cell.textLabel.text = user.name;
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView inviteCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InviteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Practice Game";
    }
    
    else {
        Invite * invite = [self.invites objectAtIndex:indexPath.row-1];
        if (invite.inviter == self.nickname) {
            cell.textLabel.text = [NSString stringWithFormat:@"You invited %@", invite.invitee];
            cell.userInteractionEnabled = NO;
            cell.backgroundColor = [UIColor colorWithRed:0.827 green:0.820 blue:0.204 alpha:1.000];
            cell.textLabel.textColor = [UIColor colorWithWhite:0.149 alpha:1.000];
        }
        else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ challenges you!", invite.inviter];
            cell.userInteractionEnabled = YES;
            cell.backgroundColor = [UIColor colorWithRed:0.490 green:0.706 blue:0.275 alpha:1.000];
            cell.textLabel.textColor = [UIColor colorWithWhite:0.149 alpha:1.000];
        }
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

-(void)createInvite:(User*)user {
    Invite * invite = [Invite new];
    invite.inviter = self.nickname;
    invite.invitee = user.name;
    
    Firebase * inviteNode = [self.firebaseInvites childByAppendingPath:invite.inviteId];
    [inviteNode setValue:invite.toObject];
    [inviteNode onDisconnectRemoveValue];
        
    // listen to the created invite for acceptance
    Firebase * matchIDNode = [inviteNode childByAppendingPath:@"matchID"];
    NSLog(@"MATCH ID NODE %@", matchIDNode);
    [matchIDNode observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value != [NSNull null]) {
            NSLog(@"Inivite Changed %@", snapshot.value);
            // match has begun! join up
            self.matchID = snapshot.value;
            invite.matchID = self.matchID;
            [self joinMatch:invite playerName:self.nickname];
        }
    }];
}

-(void)selectInvite:(Invite*)invite {
    // start the match!
    NSString * matchID = [NSString stringWithFormat:@"%i", arc4random()];
    invite.matchID = matchID;
    
    Firebase* inviteNode = [self.firebaseInvites childByAppendingPath:invite.inviteId];
    [inviteNode setValue:invite.toObject];
    [inviteNode onDisconnectRemoveValue];
    [self joinMatch:invite playerName:self.nickname];
}

-(void)startPracticeGame {
    NSString * matchID = [NSString stringWithFormat:@"%i", arc4random()];
    Player * ai = [Player new];
    ai.name = @"zzzai";
    [self startGameWithMatchId:matchID player:self.currentPlayer withAI:ai];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self startPracticeGame];
        }
        else {
            Invite * invite = [self.invites objectAtIndex:indexPath.row-1];
            [self selectInvite:invite];
        }
    } else {
        User* user = [self.users objectAtIndex:indexPath.row];
        [self createInvite:user];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
