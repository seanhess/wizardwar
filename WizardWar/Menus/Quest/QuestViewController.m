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
    
    self.title = @"Quest";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"SpellbookCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SpellbookCell"];
    
    
    self.levels = [QuestService.shared allQuestLevels];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewStuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.levels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
//    if (questLevel.wizardLevel > 0)
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"Level %i", questLevel.wizardLevel];
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
            progress.progressView.innerColor = [UIColor clearColor];
            progress.alignCenter = YES;
        }
    }
    

    
    // You can do "mastered" once it's 100%
    
    cell.textLabel.text = questLevel.name;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QuestLevel * questLevel = [self.levels objectAtIndex:indexPath.row];
    id<AIService>ai = [questLevel.AIType new];
    
    MatchViewController * match = [[MatchViewController alloc] init];
    [match createMatchWithWizard:UserService.shared.currentWizard withAI:ai];
//    self.match = match;
    [self.navigationController presentViewController:match animated:YES completion:nil];
    [match startMatch];
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 54;
//}





@end
