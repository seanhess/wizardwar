//
//  FriendsViewController.m
//  WizardWar
//
//  Created by Sean Hess on 7/16/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "FriendsViewController.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>
#import <FacebookSDK/FacebookSDK.h>
#import "UserFriendService.h"
#import "UserService.h"
#import "ObjectStore.h"
#import "FacebookUser.h"

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController * friends;

@end

@implementation FriendsViewController

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
    
    self.title = @"Facebook Friends";
    
    // Load them from the server
    User * user = [UserService.shared currentUser];
    [UserFriendService.shared user:user loadFacebookFriends:nil];
    
    // Display cached friends
    NSError * error = nil;
    NSFetchRequest * request = [UserFriendService.shared requestFacebookFriends];
    self.friends = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:ObjectStore.shared.context sectionNameKeyPath:@"lastName" cacheName:nil];
    self.friends.delegate = self;
    [self.friends performFetch:&error];

    
    
    
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.frame = CGRectMake(0, 0, 100, 100);
//    [self.view addSubview:loginView];
    
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    // Align the button in the center horizontally
//    loginView.frame = CGRectOffset(loginView.frame,
//                                   (self.view.center.x - (loginView.frame.size.width / 2)),
//                                   5);
//    [self.view addSubview:loginView];
//    [loginView sizeToFit];

    
    return;
    
//    NSLog(@"WOOT");
//    Firebase * firebase = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseio.com/"];
//    FirebaseSimpleLogin* authClient = [[FirebaseSimpleLogin alloc] initWithRef:firebase];

//    [authClient checkAuthStatusWithBlock:^(NSError* error, FAUser* user) {
//        if (error != nil) {
//            // Oh no! There was an error performing the check
//            NSLog(@"ERROR");
//        } else if (user == nil) {
//            // No user is logged in
//            NSLog(@"NO LOGGED IN");
//        } else {
//            // There is a logged in user
//            NSLog(@"LOGGED IN");
//        }
//    }];
    
//    [authClient loginToFacebookAppWithId:@"150922078436714" permissions:@[@"email"] audience:ACFacebookAudienceOnlyMe withCompletionBlock:^(NSError *error, FAUser *user) {
//         if (error != nil) {
//             // There was an error logging in
//             NSLog(@"ERROR %@", error);
//         } else {
//             // We have a logged in facebook user
//             NSLog(@"LOGGED IN %@", user);
//         }
//     }];
//    
//    Firebase* authRef = [firebase.root childByAppendingPath:@".info/authenticated"];
//    
//    [authRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snap) {
////        BOOL isAuthenticated = [snap.value boolValue];
//    }];
//    
//    [authClient logout];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //    [self.tableView reloadData];
    [self.tableView reloadData];
}




#pragma mark tableview


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.friends.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends.sections[section] numberOfObjects];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return nil;
//}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.friends sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.friends sectionForSectionIndexTitle:title atIndex:index];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.friends sections] objectAtIndex:section];
//    return [sectionInfo name];
//}

//- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
//    return 0;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FacebookFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    FacebookUser * user = [self.friends objectAtIndexPath:indexPath];
    cell.textLabel.text = user.name;
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 44;
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
