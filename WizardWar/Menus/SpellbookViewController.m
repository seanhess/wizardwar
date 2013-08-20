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
    
    self.spells = [SpellbookService.shared allSpellRecords];    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.spells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SpellbookCell";
    SpellbookCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[SpellbookCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//        cell.textLabel.font = [UIFont fontWithName:@"FontAwesome" size:14];
    }
    
    SpellRecord * spell = [self.spells objectAtIndex:indexPath.row];

    cell.nameLabel.text = [self spellTitle:spell];
    cell.nameLabel.enabled = spell.isUnlocked;
    
    [cell setSpellRecord:spell];
    return cell;
}

- (NSString*)spellTitle:(SpellRecord*)record {
    if (record.isDiscovered) {
        return record.name;
    } else {
        return @"?";
    }    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SpellRecord * spell = [self.spells objectAtIndex:indexPath.row];
    

    if (spell.isUnlocked) {
        SpellbookDetailsViewController * details = [SpellbookDetailsViewController new];
        details.spell = spell;
        [self.navigationController pushViewController:details animated:YES];
    } else if (spell.isDiscovered) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[self spellTitle:spell] message:@"Cast this spell in 5 matches to unlock" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[self spellTitle:spell] message:@"Cast this spell once to discover it" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [alert show];
    }
}



@end
