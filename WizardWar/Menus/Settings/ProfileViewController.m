//
//  ProfileViewController.m
//  WizardWar
//
//  Created by Sean Hess on 7/16/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "ProfileViewController.h"
#import "ComicZineDoubleLabel.h"
#import "TestFlight.h"
#import <BButton.h>
#import "InfoService.h"
#import "UserService.h"
#import <QuartzCore/QuartzCore.h>
#import "SettingsProfileCell.h"
#import "AccountColorViewController.h"
#import <WEPopoverController.h>
#import "UserFriendService.h"
#import "SettingsFacebookButtonCell.h"
#import "AnalyticsService.h"
#import <MessageUI/MessageUI.h>
#import "QuestService.h"
#import "SpellbookService.h"

#define SECTION_FACEBOOK 1
#define SECTION_PROFILE 0

#define ROW_NAME 0
#define ROW_LEVEL 1
#define ROW_COLOR 2
#define ROW_AVATAR 3

@interface ProfileViewController () <AccountColorDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) WEPopoverController * popover;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ProfileViewController

-(id)init {
    if ((self = [super init])) {
        self.title = @"My Wizard";
    }
    return self;
}

- (void)viewDidLoad
{
    [AnalyticsService event:@"profile"];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];
    
//    if (self.onDone) {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(didTapDone:)];
    self.navigationItem.rightBarButtonItem = doneButton;
//    }
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == SECTION_FACEBOOK)
        return 1;
    else if (section == SECTION_PROFILE)
        return 4;
    else
        return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTION_FACEBOOK) {
        return @"Facebook";
    } else if (section == SECTION_PROFILE) {
        return @"Wizard Profile";
    } else {
        return @"";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_FACEBOOK) {
        return [self tableView:tableView facebookCellForIndexPath:indexPath];
    } else if (indexPath.section == SECTION_PROFILE) {
        return [self tableView:tableView profileCellForIndexPath:indexPath];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView*)tableView facebookCellForIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"SettingsFacebookSettingsCell";
    SettingsFacebookButtonCell *cell = (SettingsFacebookButtonCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SettingsFacebookButtonCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    //    User * user = UserService.shared.currentUser;
    BOOL waiting = (UserFriendService.shared.facebookStatus == FBStatusConnecting);
    [cell setWaiting:waiting];
    
    if (waiting) {
        [cell setTitle:@"Connecting..."];
    } else if ([UserFriendService.shared isAuthenticatedFacebook]) {
        [cell setTitle:@"Account Connected!"];
    } else {
        [cell setTitle:@"Connect Account"];
    }
    
    
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView*)tableView profileCellForIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"SettingsProfileCell";
    SettingsProfileCell *cell = (SettingsProfileCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SettingsProfileCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    User * user = [UserService.shared currentUser];
    
    if (indexPath.row == ROW_NAME) {
        cell.textLabel.text = @"Name";
        cell.inputField.delegate = self;
        [cell setFieldText:user.name];
    }
    
    else if (indexPath.row == ROW_LEVEL) {
        cell.textLabel.text = @"Level";
        cell.inputField.delegate = self;
        [cell setLabelText:[NSString stringWithFormat:@"%i", user.wizardLevel]];
    }
    
    else if (indexPath.row == ROW_COLOR) {
        cell.textLabel.text = @"Color";
        [cell setColor:user.color];
    }
    
    else if (indexPath.row == ROW_AVATAR) {
        cell.textLabel.text = @"Avatar";
        [cell setAvatarURL:[UserFriendService.shared user:user facebookAvatarURLWithSize:cell.avatarSize]];
    }
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == SECTION_FACEBOOK && ![UserFriendService.shared isAuthenticatedFacebook]) {
        return @"Connect to play with your friends and set your avatar. Will not post anything unless you explicitly share something.";
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_PROFILE && indexPath.row == ROW_AVATAR) return 108;
    return 44;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == SECTION_FACEBOOK) {
        [self didTapFacebook];
    }
        
    else if (indexPath.section == SECTION_PROFILE) {
        SettingsProfileCell * cell = (SettingsProfileCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        if (indexPath.row == ROW_NAME) {
            [cell.inputField becomeFirstResponder];
        } else if (indexPath.row == ROW_COLOR) {
            AccountColorViewController * color = [AccountColorViewController new];
            color.delegate = self;
            WEPopoverController * popover = [[WEPopoverController alloc] initWithContentViewController:color];
            [popover presentPopoverFromRect:cell.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.popover = popover;
        } else if (indexPath.row == ROW_AVATAR) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Facebook Avatar" message:@"Your avatar is set by your facebook account." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
        }
    }
}


-(void)didTapFacebook {
    if ([UserFriendService.shared isAuthenticatedFacebook]) {
        User * user = [UserService.shared currentUser];
        [AnalyticsService event:@"facebook-disconnect"];
        [UserFriendService.shared user:user disconnectFacebook:^{
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
    else {
        [self connectFacebook];
    }
}

-(void)connectFacebook {
    [AnalyticsService event:@"facebook"];
    User * user = [UserService.shared currentUser];
    [UserFriendService.shared user:user authenticateFacebook:^(BOOL success, User* updated) {
        [AnalyticsService event:@"facebook-complete"];        
        if (success) {
            // load friends now in the background
            [UserFriendService.shared user:user loadFacebookFriends:nil];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)didSelectColor:(UIColor *)color {
    [self.popover dismissPopoverAnimated:YES];
    User * user = UserService.shared.currentUser;
    user.color = color;
    [self.tableView reloadData];
}


#pragma mark - textField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

// YO YO
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length && ![textField.text isEqualToString:UserService.shared.currentUser.name]) {
        User * user = UserService.shared.currentUser;
        user.name = textField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - nextViewController
-(void)didTapDone:(id)sender {
    User * user = UserService.shared.currentUser;
    user.isGuestAccount = NO;
    SettingsProfileCell * cell = (SettingsProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:SECTION_PROFILE]];
    user.name = cell.inputField.text;
    [UserService.shared saveCurrentUser];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if (self.onDone) self.onDone();
}

@end
