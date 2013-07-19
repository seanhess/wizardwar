//
//  SettingsViewController.m
//  WizardWar
//
//  Created by Sean Hess on 7/16/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SettingsViewController.h"
#import "ComicZineDoubleLabel.h"
#import <TestFlight.h>
#import <BButton.h>
#import "AccountViewController.h"
#import "InfoService.h"
#import "UserService.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfileCell.h"

@interface SettingsViewController ()

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
    self.title = @"Settings";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];
    
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
    if (section == 0 || section == 2)
        return 1;
    else if (section == 1 || section == 3)
        return 2;
    else 
        return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Facebook";
    } else if (section == 1) {
        return @"Wizard Profile";
    } else if (section == 2) {
        return @"";
    } else {
        return @"";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self tableView:tableView facebookCellForIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        return [self tableView:tableView profileCellForIndexPath:indexPath];
    } else {
        return [self tableView:tableView infoCellForIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView*)tableView facebookCellForIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"FacebookSettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        BButton * button = [[BButton alloc] initWithFrame:cell.contentView.bounds type:BButtonTypeFacebook];
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [button setTitle:@"Connect Account" forState:UIControlStateNormal];
        [button addAwesomeIcon:FAIconFacebookSign beforeTitle:YES];        
        [cell.contentView addSubview:button];
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

    if (indexPath.section == 2) {
        cell.textLabel.text = @"Send Us Feedback";
    }

    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Build Date";
            cell.detailTextLabel.text = [InfoService buildDate];
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Version";
            cell.detailTextLabel.text = [InfoService version];
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
    
    if (indexPath.row == 0) {
        [cell setUserName:UserService.shared.currentUser];
    }
    
    else if (indexPath.row == 1) {
        [cell setUserColor:UserService.shared.currentUser];
    }
    
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
    if (indexPath.section == 0) {
        
    }
    
    else if (indexPath.section == 1) {
        AccountViewController * profile = [AccountViewController new];
        [self.navigationController pushViewController:profile animated:YES];
    }
    
    else if (indexPath.section == 2) {
        [TestFlight openFeedbackView];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
