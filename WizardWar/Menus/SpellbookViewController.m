//
//  SpellbookViewController.m
//  WizardWar
//
//  Created by Sean Hess on 8/19/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellbookViewController.h"
#import "ComicZineDoubleLabel.h"
#import "AnalyticsService.h"
#import "SpellbookService.h"
#import "ObjectStore.h"
#import "SpellbookDetailsViewController.h"
#import "SpellbookCell.h"
#import "WarningCell.h"
#import "NSArray+Functional.h"

#define SECTION_WARNINGS 0
#define SECTION_SPELLS 1

@interface SpellbookViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * spells;

@end

@implementation SpellbookViewController

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
    [AnalyticsService event:@"SpellbookLoad"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.title = @"Spellbook";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SpellbookCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SpellbookCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WarningCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"WarningCell"];    
    
    self.spells = [SpellbookService.shared allSpellRecords];    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)showExplanation {
    SpellRecord * record = [self.spells find:^BOOL(SpellRecord * record) {
        return (record.level >= SpellbookLevelAdept);
    }];
    
    return (record == nil);
}


# pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SECTION_WARNINGS) {
        if (self.showExplanation) return 1;
        else return 0;
    }
    else return [self.spells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_WARNINGS) {
        return [self tableView:tableView warningCellForRowAtIndexPath:indexPath];
    }
    
    else {
        return [self tableView:tableView spellRecordCellForIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView spellRecordCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SpellbookCell";
    SpellbookCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SpellRecord * spell = [self.spells objectAtIndex:indexPath.row];
    [cell setSpellRecord:spell];
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView warningCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WarningCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WarningCell"];

    cell.selectionStyle = UITableViewCellEditingStyleNone;
    cell.textView.text = @"You can unlock more spells by playing the Quest and Multiplayer.";
    cell.textView.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_WARNINGS) return;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SpellRecord * record = [self.spells objectAtIndex:indexPath.row];

    if (record.isUnlocked) {
        SpellbookDetailsViewController * details = [SpellbookDetailsViewController new];
        details.record = record;
        [self.navigationController pushViewController:details animated:YES];
    }
    else {
        UIAlertView * alert = [SpellbookService.shared failAlertForRecord:record];
        [alert show];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_WARNINGS) return 54;
    else return 54;
}



@end
