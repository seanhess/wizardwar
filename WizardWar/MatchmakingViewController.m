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
#import "FirebaseCollection.h"

@interface MatchmakingViewController () <MatchLayerDelegate>
@property (nonatomic, strong) CCDirectorIOS * director;
@property (nonatomic, weak) IBOutlet UITableView * tableView;

@property (nonatomic, strong) NSMutableDictionary* invites;
@property (nonatomic, strong) NSMutableDictionary* users;
@property (nonatomic, strong) FirebaseCollection* usersCollection;
@property (nonatomic, strong) FirebaseCollection* invitesCollection;
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
	// Do any additional setup after loading the view.
    
    self.title = @"Matchmaking";
    
    self.users = [NSMutableDictionary dictionary];
    self.invites = [NSMutableDictionary dictionary];
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
        [self joinLobby];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"HI");
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)joinMatch:(Invite*)invite playerName:(NSString *)playerName {
    [self startGameWithMatchId:invite.matchID player:self.currentPlayer withAI:nil];
    [self.invitesCollection removeObject:invite];
}

- (Player*)currentPlayer {
    Player * player = [Player new];
    player.name = self.nickname;
    return player;
}

// starting a game should remove ALL invites you have pending
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
    [self joinLobby];
}

#pragma mark - Firebase stuff

- (void)loadDataFromFirebase
{
    self.firebaseLobby = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/lobby"];
    self.firebaseInvites = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/invites"];
    
    void(^reloadTable)(id) = ^(id obj) {
        [self.tableView reloadData];
    };
    
    // LOBBY
    self.usersCollection = [[FirebaseCollection alloc] initWithNode:self.firebaseLobby type:[User class] dictionary:self.users];
    [self.usersCollection didAddChild:reloadTable];
    [self.usersCollection didRemoveChild:reloadTable];
    [self.usersCollection didUpdateChild:reloadTable];
    
    self.invitesCollection = [[FirebaseCollection alloc] initWithNode:self.firebaseInvites type:[Invite class] dictionary:self.invites];
    [self.invitesCollection didAddChild:reloadTable];
    [self.invitesCollection didRemoveChild:reloadTable];
    [self.invitesCollection didUpdateChild:^(Invite * invite) {
        if ([invite.inviter isEqualToString:self.nickname] && invite.matchID) {
            [self joinMatch:invite playerName:self.nickname];
        }
    }];
}

- (NSArray*)lobby {
    return [self.users.allValues filter:^BOOL(User * user) {
        return ![user.name isEqualToString:self.nickname];
    }];
}

- (NSArray*)myInvites {
    // mapping back and forth between dictionary and array representation is annoying
    return [self.invites.allValues filter:^BOOL(Invite * invite) {
        return ([invite.invitee isEqualToString:self.nickname] || [invite.inviter isEqualToString:self.nickname]);
    }];
}

- (void)joinLobby
{
    User * user = [User new];
    user.name = self.nickname;
    [self.usersCollection addObject:user withName:self.nickname];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.myInvites count];
    } else if (section == 1){
        return [self.lobby count];
    } else {
        return 1; // practice game
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
        UIImage *image = [UIImage imageNamed:@"wizard-lobby.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(((view.bounds.size.width - 159)/2),10,159,20);
        [view addSubview:imageView];
        return view;
    }
    
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 40;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self tableView:tableView inviteCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1){
        return [self tableView:tableView userCellForRowAtIndexPath:indexPath];
    } else {
        return [self tableView:tableView practiceGameCellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView practiceGameCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithWhite:0.784 alpha:1.000];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.149 alpha:1.000];
    }
    cell.textLabel.text = @"Practice Game";
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView userCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithWhite:0.784 alpha:1.000];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.149 alpha:1.000];
    }
    
    User* user = [self.lobby objectAtIndex:indexPath.row];
    cell.textLabel.text = user.name;
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView inviteCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InviteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Invite * invite = [self.myInvites objectAtIndex:indexPath.row];
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
    
    return cell;
}

#pragma mark - Table view delegate

-(void)createInvite:(User*)user {
    Invite * invite = [Invite new];
    invite.inviter = self.nickname;
    invite.invitee = user.name;
    [self.invitesCollection addObject:invite withName:invite.inviteId];
    
    // listen to the created invite for acceptance
//    Firebase * matchIDNode = [inviteNode childByAppendingPath:@"matchID"];
//    NSLog(@"MATCH ID NODE %@", matchIDNode);
//    [matchIDNode observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        if (snapshot.value != [NSNull null]) {
//            NSLog(@"Inivite Changed %@", snapshot.value);
//            // match has begun! join up
//            self.matchID = snapshot.value;
//            invite.matchID = self.matchID;
//            [self joinMatch:invite playerName:self.nickname];
//        }
//    }];
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
        Invite * invite = [self.myInvites objectAtIndex:indexPath.row];
        [self selectInvite:invite];
    } else if (indexPath.section == 1){
        User * user = [self.lobby objectAtIndex:indexPath.row];
        [self createInvite:user];
    } else {
        [self startPracticeGame];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
