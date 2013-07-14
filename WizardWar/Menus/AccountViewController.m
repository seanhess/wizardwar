//
//  AccountViewController.m
//  WizardWar
//
//  Created by Sean Hess on 6/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "AccountViewController.h"
#import "User.h"
#import "UserService.h"
#import "MatchmakingViewController.h"
#import <ReactiveCocoa.h>
#import "ComicZineDoubleLabel.h"
#import "InfoService.h"

@interface AccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@", [InfoService version]];

    self.title = @"Account";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationBar];
    
    self.nameField.text = UserService.shared.currentUser.name;
    
    RACSignal * isValid = [self.nameField.rac_textSignal map:^(NSString*text) {
        return @(text.length > 0);
    }];
    
    RAC(self.doneButton.enabled) = isValid;
//    RAC(self.doneButton.alpha) = [isValid map:^(NSNumber * isValid) {
//        return (isValid.boolValue) ? @(1.0) : @(0.5);
//    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapDone:(id)sender {
    NSString * name = self.nameField.text;
    User * user = UserService.shared.currentUser;
    user.name = name;
    [UserService.shared saveCurrentUser];
    
    [self.delegate didSubmitAccountForm:name];
}


@end
