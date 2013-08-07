//
//  HelpViewController.m
//  WizardWar
//
//  Created by Sean Hess on 8/7/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "HelpViewController.h"
#import <BButton.h>

@interface HelpViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet BButton *closeButton;

@end

@implementation HelpViewController

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
    [self.closeButton setType:BButtonTypeSuccess];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapClose:(id)sender {
    [self.delegate didTapHelpClose];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate didTapHelpClose];
}

@end
