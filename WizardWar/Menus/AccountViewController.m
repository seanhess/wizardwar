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

@interface AccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end

@implementation AccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"Account";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationBar];
    
//    UIBarButtonItem * cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didTapCancel:)];
//    self.navigationItem.rightBarButtonItem = cancel;
    
    RACSignal * isValid = [self.nameField.rac_textSignal map:^(NSString*text) {
        return @(text.length > 0);
    }];
    
    RAC(self.submitButton.enabled) = isValid;
    RAC(self.submitButton.alpha) = [isValid map:^(NSNumber * isValid) {
        return (isValid.boolValue) ? @(1.0) : @(0.5);
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSetName:(id)sender {
    NSString * name = self.nameField.text;
    User * user = [UserService.shared newUserWithName:name];
    [UserService.shared saveCurrentUser:user];
    
    [self.delegate didSubmitAccountForm:name];
}

- (IBAction)didTapCancel:(id)sender {
    [self.delegate didCancelAccountForm];
}

@end
