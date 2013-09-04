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
#import "SettingsProfileCell.h"
#import "AccountColorViewController.h"
#import "UserFriendService.h"
#import "SettingsFacebookButtonCell.h"
#import "ProfileViewController.h"
#import "AnalyticsService.h"
#import <MessageUI/MessageUI.h>
#import "QuestService.h"
#import "SpellbookService.h"

#define SECTION_FEEDBACK 0
#define SECTION_INFO 3
#define SECTION_PROFILE 1
#define SECTION_ABOUT 2

#define ROW_OPEN_SOURCE 1
#define ROW_CREDITS 0

@interface SettingsViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
@end

@implementation SettingsViewController

-(id)init {
    if ((self = [super init])) {
       self.title = @"Settings"; 
    }
    return self;
}

- (void)viewDidLoad
{
    [AnalyticsService event:@"settings"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(didTapDone:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
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
    if (section == SECTION_FEEDBACK)
        return 1;
    else if (section == SECTION_INFO) {
        // only show delete all data if debug mode
#ifdef DEBUG
        return 3;
#endif
        return 2;
    }
    else if (section == SECTION_PROFILE)
        return 1;
    else if (section == SECTION_ABOUT)
        return 2;
    else 
        return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTION_ABOUT)
        return @"About Wizard War";
    else if (section == SECTION_FEEDBACK)
        return @"";
    else
        return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView infoCellForIndexPath:indexPath];
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == SECTION_FEEDBACK) {
        return @"Please let us know if you have any problems or suggestions!";
    }
    
    else if (section == SECTION_ABOUT)
        return @"Wizard War is open source. You can get a copy of the code and improve the game!";
    return nil;
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
        cell.textLabel.text = @"Contact Us";
        cell.detailTextLabel.text = @"";
    }

    else if (indexPath.section == SECTION_INFO) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Build Date";
            cell.detailTextLabel.text = [InfoService buildDate];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Version";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%i)", [InfoService version], [InfoService buildNumber]];
        }
        else if (indexPath.row ==2) {
            cell.textLabel.text = @"Reset All Data!";
        }
    }
    
    else if (indexPath.section == SECTION_PROFILE) {
        User * user = [UserService.shared currentUser];
        cell.textLabel.text = @"My Wizard";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", user.name];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
    }
    
    else if (indexPath.section == SECTION_ABOUT) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
        if (indexPath.row == ROW_CREDITS)
            cell.textLabel.text = @"Credits";
        else
            cell.textLabel.text = @"Open Source";
        cell.detailTextLabel.text = @"";
    }
    
    return cell;    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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

    if (indexPath.section == SECTION_INFO) {
        if (indexPath.row == 2) {
            UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Reset? This will reset all quest progress, user info, and the spellbook." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reset" otherButtonTitles:nil];
            [sheet showInView:self.view];
            return;
        }
    }
    
    else if (indexPath.section == SECTION_PROFILE) {
        ProfileViewController * profile = [ProfileViewController new];
        [self.navigationController pushViewController:profile animated:YES];
    }
    
    else if (indexPath.section == SECTION_ABOUT) {
        NSString * url = nil;
        
        [AnalyticsService event:@"settings-opensource"];
        
        if (indexPath.row == ROW_CREDITS) url = [InfoService creditsUrl];
        else if (indexPath.row == ROW_OPEN_SOURCE) url = [InfoService openSourceUrl];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    
    else if (indexPath.section == SECTION_FEEDBACK) {
//        [TestFlight openFeedbackView];
        if (![MFMailComposeViewController canSendMail]) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Cannot send email" message:@"Email is not enabled on your system. Please add an email account to contact us" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        [AnalyticsService event:@"feedback"];
        
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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // reset all
        [UserService.shared deleteAllData];
        [QuestService.shared deleteAllData];
        [SpellbookService.shared deleteAllData];
        [self.tableView reloadData];
    }
    return;
}

#pragma mark - nextViewController
-(void)didTapDone:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if (self.onDone) self.onDone();
}


#pragma mark - Mail Composer 
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (result == MFMailComposeResultSent)
        [AnalyticsService event:@"feedback-complete"];
    else
        [AnalyticsService event:@"feedback-cancel"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
