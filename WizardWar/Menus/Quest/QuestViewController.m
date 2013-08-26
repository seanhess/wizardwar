//
//  QuestViewController.m
//  WizardWar
//
//  Created by Sean Hess on 8/23/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "QuestViewController.h"
#import "ComicZineDoubleLabel.h"
#import "QuestService.h"
#import "ProgressAccessoryView.h"
#import "UserService.h"
#import "AppStyle.h"
#import <BButton.h>
#import "MatchViewController.h"
#import "WarningCell.h"
#import "AnalyticsService.h"
#import "ProfileViewController.h"
#import "ProfileCell.h"

#define SECTION_STATS 0
#define SECTION_LEVELS 1

@interface QuestViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * levels;
@property (strong, nonatomic) MatchViewController * match;
@end

@implementation QuestViewController

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
    
//    NSString * buttonText = [NSString stringFromAwesomeIcon:FAIconUser];
//    UIBarButtonItem *accountButton = [[UIBarButtonItem alloc] initWithTitle:buttonText style:UIBarButtonItemStylePlain target:self action:@selector(didTapAccount)];
//    [accountButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FontAwesome" size:20.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
//    self.navigationItem.rightBarButtonItem = accountButton;
    
    
    self.title = @"Quest";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];
    
    [self.tableView registerNib:[UINib nibWithNibName:[ProfileCell identifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[ProfileCell identifier]];
    
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"SpellbookCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SpellbookCell"];
    
    
    self.levels = [QuestService.shared allQuestLevels];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

#pragma mark - UITableViewStuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_LEVELS+1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SECTION_STATS) return 1;
    return self.levels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_STATS) {
        return [self tableView:tableView infoCellForIndexPath:indexPath];
    }
    
    else {
        return [self tableView:tableView questCellForIndexPath:indexPath];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView infoCellForIndexPath:(NSIndexPath *)indexPath {
    
    ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:[ProfileCell identifier]];
    
    User * user = [UserService.shared currentUser];
    [cell setUser:user];
    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView questCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"QuestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //        cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:14];
        cell.accessoryView = [[ProgressAccessoryView alloc] initWithFrame:CGRectMake(220, 0, 90, 44)];
    }

    QuestLevel * questLevel = [self.levels objectAtIndex:indexPath.row];
    User * user = [UserService.shared currentUser];
    
    ProgressAccessoryView * progress = (ProgressAccessoryView*)cell.accessoryView;
    progress.progressView.progress = questLevel.progress;
    progress.showLock = NO;
    cell.textLabel.textColor = [UIColor darkTextColor];
    
    // Should I add the level of the encounter here?
    // Think more about this
    if (questLevel.wizardLevel > WIZARD_LEVEL_PAST_TUTORIAL)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Level %i", questLevel.wizardLevel];
//    else
//        cell.detailTextLabel.text = nil;
    
    if ([QuestService.shared isLocked:questLevel user:user]) {
        progress.showLock = YES;
        cell.textLabel.textColor = [AppStyle grayLockedColor];
    }
    
    else if (questLevel.isMastered) {
        progress.progressColor = [AppStyle greenOnlineColor];
        progress.label.textColor = [UIColor whiteColor];
        progress.alignCenter = YES;
        progress.label.text = @"MASTER";
    }

    else {
        progress.progressColor = [AppStyle blueNavColor];
        progress.label.textColor = [AppStyle blueNavColor];
        
        if (questLevel.hasAttempted) {
            progress.label.text = [NSString stringWithFormat:@"Won %i:%i", questLevel.gamesWins, questLevel.gamesLosses];
            progress.alignCenter = NO;            
        } else {
            progress.label.text = @"NEW";
            progress.label.textColor = [AppStyle redErrorColor];
            progress.progressView.innerColor = [UIColor clearColor];
            progress.progressView.outerColor = [AppStyle redErrorColor];
            progress.alignCenter = YES;
        }
    }
    // You can do "mastered" once it's 100%
    
    cell.textLabel.text = questLevel.name;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_STATS) {
        [self didTapAccount];
        return;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    User * user = [UserService.shared currentUser];
    QuestLevel * questLevel = [self.levels objectAtIndex:indexPath.row];

    if ([QuestService.shared isLocked:questLevel user:user]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You're not ready!" message:@"Beat the previous levels before playing this one" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    MatchViewController * match = [[MatchViewController alloc] init];
    [match createMatchWithWizard:UserService.shared.currentWizard withLevel:questLevel];
    [self.navigationController presentViewController:match animated:YES completion:nil];
    [match startMatch];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_STATS) return [ProfileCell height];
    else return 48;
}





- (IBAction)didTapAccount {
    [AnalyticsService event:@"ProfileTap"];
    ProfileViewController * settings = [ProfileViewController new];
    UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:settings];
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}






@end
