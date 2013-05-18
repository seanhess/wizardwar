//
//  MatchmakingViewController.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "MatchmakingViewController.h"
#import "IntroLayer.h"
#import "WWDirector.h"
#import "CCScene+Layers.h"
#import "MatchLayer.h"
#import "MatchmakingTableViewController.h"
#import "UserCell.h"
#import "InviteCell.h"

@interface MatchmakingViewController ()

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
    self.matchesTableViewController = [[MatchmakingTableViewController alloc] initWithStyle:UITableViewStylePlain];
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)joinMatch:(NSString *)matchID playerName:(NSString *)playerName {
    NSLog(@"joining match %@ with %@", matchID, playerName);
    // hide the navigation bar first, so the size of this view is correct!
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    CCDirectorIOS * director = [WWDirector directorWithBounds:self.view.bounds];
    [director runWithScene:[CCScene sceneWithLayer:[[MatchLayer alloc] initWithMatchId:matchID playerName:playerName]]];
    // [self.navigationController pushViewController:director animated:YES];
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
    
    [self.firebaseLobby observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value[@"name"] != self.nickname) {
            [self.users addObject:snapshot.value];
            [self.matchesTableViewController.tableView reloadData];
        }
    }];
    
    [self.firebaseInvites observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot.value[@"invitee"] isEqualToString:self.nickname]) {
            [self.invites addObject:snapshot.value];
            [self.matchesTableViewController.tableView reloadData];
        }
    }];
    
    [self.firebaseLobby observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        for (id user in self.users) {
            if ([user[@"name"] isEqualToString:snapshot.value[@"name"]]) {
                [self.users removeObjectIdenticalTo:user];
            }
        }
        [self.matchesTableViewController.tableView reloadData];
    }];
    
    [self.firebaseInvites observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        for (id invite in self.invites) {
            if ([invite[@"inviter"] isEqualToString:snapshot.value[@"inviter"]] && [invite[@"initee"] isEqualToString:snapshot.value[@"invitee"]]) {
                [self.invites removeObjectIdenticalTo:invite];
            }
        }
        [self.matchesTableViewController.tableView reloadData];
    }];
}

- (void)addToLobbyList
{
    Firebase * userNode = [self.firebaseLobby childByAppendingPath:self.nickname];
    [userNode setValue:@{@"name": self.nickname}];
    [userNode onDisconnectRemoveValue];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.invites count];
    } else {
        return [self.users count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Invites";
    } else {
        return @"Lobby";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.section == 0) {
        InviteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[InviteCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        NSDictionary* invite = [self.invites objectAtIndex:indexPath.row];
        
        cell.textLabel.text = invite[@"inviter"];
        return cell;
    } else {
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        NSDictionary* user = [self.users objectAtIndex:indexPath.row];
        
        cell.textLabel.text = user[@"name"];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // start the match!
        self.matchID = [NSString stringWithFormat:@"%i", arc4random()];
        Firebase* matchNode = [self.firebaseMatches childByAppendingPath:self.matchID];
        [matchNode onDisconnectRemoveValue];
        NSDictionary* invite = [self.invites objectAtIndex:indexPath.row];
        NSString* inviteKey = [[NSString alloc] initWithFormat:@"%@-%@/matchID", invite[@"inviter"], invite[@"invitee"]];
        Firebase* inviteNode = [self.firebaseInvites childByAppendingPath:inviteKey];
        [inviteNode setValue:self.matchID];
        [inviteNode onDisconnectRemoveValue];
        [(MatchmakingViewController *)self.parentViewController joinMatch:self.matchID playerName:invite[@"inviter"]];
    } else {
        // create an invite
        NSDictionary* user = [self.users objectAtIndex:indexPath.row];
        NSString* inviteKey = [[NSString alloc] initWithFormat:@"%@-%@", self.nickname, user[@"name"]];
        Firebase * inviteNode = [self.firebaseInvites childByAppendingPath:inviteKey];
        [inviteNode setValue:@{@"inviter": self.nickname, @"invitee": user[@"name"]}];
        [inviteNode onDisconnectRemoveValue];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // listen to the created invite for acceptance
        NSString *invitePath = [NSString stringWithFormat:@"https://wizardwar.firebaseio.com/invites/%@", inviteKey];
        NSLog(@"listening to %@", invitePath);
        Firebase* invite = [[Firebase alloc] initWithUrl:invitePath];
        [invite observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
            NSLog(@"Inivite Changed %@", snapshot.value);
            if ([snapshot.value hasChildAtPath:@"matchID"]) {
                // match has begun! join up
                self.matchID = snapshot.value[@"matchID"];
                [(MatchmakingViewController *)self.parentViewController joinMatch:self.matchID playerName:user[@"name"]];
            }
        }];
    }
}

@end
