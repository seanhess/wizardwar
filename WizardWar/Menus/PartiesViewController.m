//
//  WizardPartyViewController.m
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PartiesViewController.h"
#import "LocalParty.h"
#import "PartyInviteViewController.h"
#import "PartyViewController.h"

@interface PartiesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * parties; // Array of parties!
@property (strong, nonatomic) User * user;

// need to add the local lobby
@end

@implementation PartiesViewController

- (id)initWithUser:(User*)user {
    self = [super init];
    if (self) {
        self.user = user;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Wizard Parties!";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // You only want to add the local party if there are people near you
    // But we DO want to show how many people are in there
//    NSArray * local = @[[LocalParty new]];
//    self.parties = [local arrayByAddingObjectsFromArray:self.user.parties];
    
    // Do any additional setup after loading the view from its nib.
    
    // 1. the local wizard party
    // 2. any parties you otherwise have
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapMatchmaking:(id)sender {

}

- (IBAction)didTapStartParty:(id)sender {
    // goes to invite people and stuff
    PartyInviteViewController * invites = [PartyInviteViewController new];
    [self.navigationController pushViewController:invites animated:YES];
}





#pragma mark TableView


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.parties.count;
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
    static NSString *CellIdentifier = @"LobbyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Party * party = self.parties[indexPath.row];
    cell.textLabel.text = party.name;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Party * party = self.parties[indexPath.row];
    PartyViewController * vc = [PartyViewController new];
    vc.party = party;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
