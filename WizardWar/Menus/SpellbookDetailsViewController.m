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
#import "SpellEffectService.h"
#import "SpellInfo.h"
#import "Spell.h"

#define SECTION_INFO 0
#define SECTION_STATS 1
#define SECTION_EFFECT 2
#define SECTION_INTERACTIONS 3

@interface EffectStat : NSObject
@property (nonatomic, strong) NSString * name;
@property (nonatomic) NSInteger value;
@end

@implementation EffectStat
@end



@interface SpellbookDetailsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * interactions;
@property (strong, nonatomic) Spell * spell;
@property (strong, nonatomic) NSMutableArray * effectStats;

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
    self.spell = [Spell fromType:self.record.info.type];
    self.effectStats = [NSMutableArray array];
    if (self.spell.damage > 0) {
        EffectStat * stat = [EffectStat new];
        stat.name = @"Damage";
        stat.value = self.spell.damage;
        [self.effectStats addObject:stat];
    }
    if (self.spell.speed > 0) {
        EffectStat * stat = [EffectStat new];
        stat.name = @"Speed";
        stat.value = self.spell.speed;
        [self.effectStats addObject:stat];
    }
    
    
    
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
    else if (section == SECTION_EFFECT) {
        return self.effectStats.count + 1;
    }
    else if (section == SECTION_INTERACTIONS) return self.interactions.count;
    else return 0;
}

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == SECTION_INFO) return @"Info";
//    else if (section == SECTION_STATS) return @"Stats";
//    else if (section == SECTION_EFFECT) return @"Effect";
//    else if (section == SECTION_INTERACTIONS) return @"Interactions";
//    else return @"";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_INFO) return [self infoCell:tableView];
    else if (indexPath.section == SECTION_STATS) return [self statsCell:tableView];
    else if (indexPath.section == SECTION_EFFECT) return [self tableView:tableView effectCellForIndexPath:indexPath];
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

- (UITableViewCell *)tableView:(UITableView*)tableView effectCellForIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0) {
        return [self tableView:tableView descriptionCell:self.description];
    } else {
        EffectStat * stat = [self.effectStats objectAtIndex:indexPath.row-1];
        return [self tableView:tableView statCellWithKey:stat.name value:stat.value];
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView statCellWithKey:(NSString*)key value:(NSInteger)value {
    static NSString *CellIdentifier = @"SpellbookStatCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = key;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", value];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView descriptionCell:(NSString*)description {
    static NSString *CellIdentifier = @"SpellbookDescriptionCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = self.descriptionFont;
    }
    cell.textLabel.text = description;
    return cell;
}

- (NSString*)description {
    return @"asdlkjfasdjlfk asfdjlk jafldksjkl afdsjkl adfsjkl afsdljk afdsljk fadsljk afsdljk flajdsljk asdljk fsadljk afsdljk afdsljkfadsljk fdsaljkdflsajkdfskjkl fdsklj dsafjl kadfsjkl afdsjkl UGLY HEAD";
}

- (UIFont*)descriptionFont {
    return [UIFont fontWithName:@"Helvetica" size:17.0];
}





//-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    if (section == 0 && ![UserFriendService.shared isAuthenticatedFacebook]) {
//        return @"Connect to play with your friends and set your avatar. Will not post anything unless you explitly share something.";
//    }
//    return nil;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_INFO) return SPELLBOOK_INFO_HEIGHT;
    if (indexPath.section == SECTION_EFFECT) {
        if (indexPath.row == 0) {
            CGSize constraintSize = CGSizeMake(self.view.frame.size.width, MAXFLOAT);
            CGSize labelSize = [self.description sizeWithFont:self.descriptionFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            return labelSize.height + 20;
        }
    }
//    else if (indexPath.section == SECTION_EFFECT) {
//        if (indexPath.row == 1 && self.spell.damage == 0) return 0;
//        if (indexPath.row == 2 && self.spell.speed == 0) return 0;
//    }
//    else if (indexPath.section == SECTION_CAST) return SPELLBOOK_DIAGRAM_HEIGHT;
    return 44;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
