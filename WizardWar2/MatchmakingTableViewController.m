//
//  MatchmakingTableViewController.m
//  WizardWar
//
//  Created by Clay Ferris on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "MatchmakingTableViewController.h"
#import "MatchLayer.h"
#import "UserCell.h"
#import "InviteCell.h"

@interface MatchmakingTableViewController ()

@end

@implementation MatchmakingTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [self.firebaseLobby observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value[@"name"] != self.nickname) {
            [self.users addObject:snapshot.value];
            [self.tableView reloadData];
        }
    }];
    
    [self.firebaseInvites observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot.value[@"invitee"] isEqualToString:self.nickname]) {
            [self.invites addObject:snapshot.value];
            [self.tableView reloadData];
        }
    }];
    
    [self.firebaseLobby observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        for (id user in self.users) {
            if ([user[@"name"] isEqualToString:snapshot.value[@"name"]]) {
                [self.users removeObjectIdenticalTo:user];
            }
        }
        [self.tableView reloadData];
    }];
    
    [self.firebaseInvites observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        for (id invite in self.invites) {
            if ([invite[@"inviter"] isEqualToString:snapshot.value[@"inviter"]] && [invite[@"initee"] isEqualToString:snapshot.value[@"invitee"]]) {
                [self.invites removeObjectIdenticalTo:invite];
            }
        }
        [self.tableView reloadData];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // start the match!        
    } else {
        // create an invite
        NSDictionary* user = [self.users objectAtIndex:indexPath.row];
        Firebase * inviteNode = [self.firebaseInvites childByAppendingPath:[[NSString alloc] initWithFormat:@"%@-%@", self.nickname, user[@"name"]]];
        [inviteNode setValue:@{@"inviter": self.nickname, @"invitee": user[@"name"]}];
        [inviteNode onDisconnectRemoveValue];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
