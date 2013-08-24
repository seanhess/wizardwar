//
//  SettingsViewController.m
//  WizardWar
//
//  Created by Sean Hess on 7/16/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SettingsViewController.h"
#import "ComicZineDoubleLabel.h"
#import "TestFlight.h"
#import <BButton.h>
#import "InfoService.h"
#import "UserService.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfileCell.h"
#import "AccountColorViewController.h"
#import <WEPopoverController.h>
#import "UserFriendService.h"
#import "FacebookButtonCell.h"
#import "AnalyticsService.h"
#import <MessageUI/MessageUI.h>

#define SECTION_FEEDBACK 0
#define SECTION_FACEBOOK 1
#define SECTION_PROFILE 2
#define SECTION_INFO 3

@interface SettingsViewController () <AccountColorDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) WEPopoverController * popover;

@end

@implementation SettingsViewController

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
    [AnalyticsService event:@"SettingsLoad"];    
    self.title = @"Settings";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];
    
    if (self.onDone) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(didTapDone:)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == SECTION_FACEBOOK)
        return 1;
    else if (section == SECTION_PROFILE)
        return 3;
    else if (section == SECTION_FEEDBACK && self.showFeedback)
        return 1;
    else if (section == SECTION_INFO && self.showBuildInfo)
        return 2;
    else 
        return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTION_FACEBOOK) {
        return @"Facebook";
    } else if (section == SECTION_PROFILE) {
        return @"Wizard Profile";
    } else if (section == SECTION_FEEDBACK) {
        return @"";
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
        return [self tableView:tableView infoCellForIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView*)tableView facebookCellForIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"FacebookSettingsCell";
    FacebookButtonCell *cell = (FacebookButtonCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FacebookButtonCell alloc] initWithReuseIdentifier:CellIdentifier];
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

- (UITableViewCell *)tableView:(UITableView*)tableView infoCellForIndexPath:(NSIndexPath*)indexPath {
    static NSString *CellIdentifier = @"InfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (indexPath.section == SECTION_FEEDBACK) {
        cell.textLabel.text = @"Send Us Feedback";
    }

    else if (indexPath.section == SECTION_INFO) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Build Date";
            cell.detailTextLabel.text = [InfoService buildDate];
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Version";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%i)", [InfoService version], [InfoService buildNumber]];
        }
    }
    
    return cell;    
}

- (UITableViewCell *)tableView:(UITableView*)tableView profileCellForIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"ProfileCell";
    ProfileCell *cell = (ProfileCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ProfileCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    User * user = [UserService.shared currentUser];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Name";
        cell.inputField.delegate = self;
        [cell setFieldText:user.name];
    }
    
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Color";
        [cell setColor:user.color];
    }
    
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"Avatar";
        [cell setAvatarURL:[UserFriendService.shared user:user facebookAvatarURLWithSize:cell.avatarSize]];
    }
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == SECTION_FACEBOOK && ![UserFriendService.shared isAuthenticatedFacebook]) {
        return @"Connect to play with your friends and set your avatar. Will not post anything unless you explitly share something.";
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_PROFILE && indexPath.row == 2) return 108;
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
        ProfileCell * cell = (ProfileCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            [cell.inputField becomeFirstResponder];
        } else if (indexPath.row == 1) {
            AccountColorViewController * color = [AccountColorViewController new];
            color.delegate = self;
            WEPopoverController * popover = [[WEPopoverController alloc] initWithContentViewController:color];
            [popover presentPopoverFromRect:cell.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.popover = popover;
        } else if (indexPath.row == 2) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Facebook Avatar" message:@"Your avatar is set by your facebook account." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
        }
    }
    
    else if (indexPath.section == SECTION_FEEDBACK) {
//        [TestFlight openFeedbackView];
        if (![MFMailComposeViewController canSendMail]) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Cannot send email" message:@"Email is not enabled on your system. Please add an email account to contact us" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }

        
        MFMailComposeViewController *picker = [MFMailComposeViewController new];
        picker.mailComposeDelegate = self;
        
//        [picker setSubject:@"Hello from California!"];
        
        // Set up recipients
        NSArray *toRecipients = [NSArray arrayWithObject:InfoService.supportEmail];
//        NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
//        NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
        
        [picker setToRecipients:toRecipients];
//        [picker setCcRecipients:ccRecipients];
//        [picker setBccRecipients:bccRecipients];
        
        // Attach an image to the email
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"jpg"];
//        NSData *myData = [NSData dataWithContentsOfFile:path];
//        [picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"rainy"];
        
        // Fill out the email body text
        NSString * version = [NSString stringWithFormat:@"%@ (%i)", [InfoService version], [InfoService buildNumber]];
        NSString * userId = [[UserService.shared currentUser] userId];
        NSString *emailBody = [NSString stringWithFormat:@"\n\n------\nVersion: %@\nUserId: %@", version, userId];
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    

}

-(void)didTapFacebook {
    if ([UserFriendService.shared isAuthenticatedFacebook]) {
        User * user = [UserService.shared currentUser];
        [AnalyticsService event:@"FacebookDisconnectTap"];            
        [UserFriendService.shared user:user disconnectFacebook:^{
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
    else {
        [self connectFacebook];
    }
}

-(void)connectFacebook {
    [AnalyticsService event:@"FacebookConnectTap"];        
    User * user = [UserService.shared currentUser];
    [UserFriendService.shared user:user authenticateFacebook:^(BOOL success, User* updated) {
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
    ProfileCell * cell = (ProfileCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:SECTION_PROFILE]];
    user.name = cell.inputField.text;
    [UserService.shared saveCurrentUser];
    
    if (self.onDone) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        self.onDone();
    }
}


#pragma mark - Mail Composer 
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
