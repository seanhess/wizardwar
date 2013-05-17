//
//  MatchmakingTableViewController.m
//  WizardWar
//
//  Created by Clay Ferris on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "MatchmakingTableViewController.h"
#import "MatchCell.h"

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
    self.matches = [[NSMutableArray alloc] init];
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
        [self addToMatchList];
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
    [self addToMatchList];
}

#pragma mark - Firebase stuff

- (void)loadDataFromFirebase
{
    self.firebase = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/matchmaking"];
    
    [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value[@"name"] != self.nickname) {
            [self.matches addObject:snapshot.value];
            [self.tableView reloadData];
        }
    }];
    
    [self.firebase observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        for (id match in self.matches) {
            if (match[@"name"] == snapshot.value[@"name"]) {
                [self.matches removeObjectIdenticalTo:match];
            }
        }
        [self.tableView reloadData];
    }];
}

- (void)addToMatchList
{
    Firebase * userNode = [self.firebase childByAppendingPath:self.nickname];
    [userNode setValue:@{@"name": self.nickname}];
    [userNode onDisconnectRemoveValue];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.matches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MatchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MatchCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* match = [self.matches objectAtIndex:indexPath.row];
    NSLog(@"adding match: %@", match);
    
    cell.textLabel.text = match[@"name"];
    
    return cell;
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
    NSDictionary* match = [self.matches objectAtIndex:indexPath.row];
    NSLog(@"Invite %@", match);

}

@end
