//
//  SpellbookDetailsViewController.m
//  WizardWar
//
//  Created by Sean Hess on 8/19/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellbookDetailsViewController.h"
#import "ComicZineDoubleLabel.h"
#import "SpellbookCastDiagramView.h"
#import "SpellbookInfoView.h"
#import "SpellbookProgressView.h"

#define SECTION_INFO 0
#define SECTION_STATS 1
#define SECTION_EFFECT 2
#define SECTION_INTERACTIONS 3

@interface SpellbookDetailsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * interactions;

@end

@implementation SpellbookDetailsViewController

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
    self.title = self.record.name;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];
    
    self.interactions = @[@"asdf", @"asdf", @"asdf"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}









#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == SECTION_INFO) return 1;
    else if (section == SECTION_STATS) return 1;
    else if (section == SECTION_EFFECT) return 1;
    else if (section == SECTION_INTERACTIONS) return self.interactions.count;
    else return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTION_INFO) return @"Info";
    else if (section == SECTION_STATS) return @"Stats";
    else if (section == SECTION_EFFECT) return @"Effect";
    else if (section == SECTION_INTERACTIONS) return @"Interactions";
    else return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_INFO) return [self infoCell:tableView];
    else if (indexPath.section == SECTION_STATS) return [self statsCell:tableView];
    else if (indexPath.section == SECTION_EFFECT) return [self effectCell:tableView];
    else if (indexPath.section == SECTION_INTERACTIONS) return [self tableView:tableView interactionCellForIndexPath:indexPath];
    else return nil;
}

- (UITableViewCell *)infoCell:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"SpellbookInfoCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    SpellbookInfoView * infoView;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        infoView = [[SpellbookInfoView alloc] initWithFrame:cell.contentView.bounds];
        infoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:infoView];
    } else {
        infoView = cell.contentView.subviews[0];
    }
    
    infoView.record = self.record;
    
//    cell.textLabel.text = @"INFO";
    return cell;
}

- (UITableViewCell *)statsCell:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"SpellbookCastCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryView = [[SpellbookProgressView alloc] initWithFrame:CGRectMake(220, 0, 100, 44)];
    }
    
    SpellbookProgressView * progressView = (SpellbookProgressView*)cell.accessoryView;
    progressView.record = self.record;
    cell.textLabel.text = [NSString stringWithFormat:@"%i Matches", self.record.castUniqueMatches];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i Casts", self.record.castTotal];
    
    return cell;
}

- (UITableViewCell *)effectCell:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"SpellbookEffectCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = @"EFFECT";
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView interactionCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SpellbookInteractionCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = @"INTERACTION";
    return cell;
}


//-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    if (section == 0 && ![UserFriendService.shared isAuthenticatedFacebook]) {
//        return @"Connect to play with your friends and set your avatar. Will not post anything unless you explitly share something.";
//    }
//    return nil;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_INFO) return SPELLBOOK_INFO_HEIGHT;
//    else if (indexPath.section == SECTION_CAST) return SPELLBOOK_DIAGRAM_HEIGHT;
    return 44;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
