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
#import <QuartzCore/QuartzCore.h>
#import <BButton.h>
#import "NSArray+Functional.h"
#import <WEPopoverController.h>
#import "UIColor+Hex.h"
#import "AccountColorViewController.h"



@interface AccountViewController () <AccountColorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet BButton *colorButton;

@property (strong, nonatomic) WEPopoverController * popover;

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
    
//    [self.colorButton setBac]
    NSLog(@"Account Color: %@ vs %i", UserService.shared.currentUser.color, UserService.shared.currentUser.colorRGB);
    self.colorButton.color = UserService.shared.currentUser.color;
    
//    RAC(self.doneButton.alpha) = [isValid map:^(NSNumber * isValid) {
//        return (isValid.boolValue) ? @(1.0) : @(0.5);
//    }];
    
    [self.nameField becomeFirstResponder];
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

- (IBAction)didTapColor:(id)sender {
    AccountColorViewController * color = [AccountColorViewController new];
    color.delegate = self;
    WEPopoverController * popover = [[WEPopoverController alloc] initWithContentViewController:color];
    [popover presentPopoverFromRect:self.colorButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.popover = popover;
}

- (void)didSelectColor:(UIColor *)color {
    [self.popover dismissPopoverAnimated:YES];
    User * user = UserService.shared.currentUser;
    user.color = color;
    self.colorButton.color = color;
}

@end
