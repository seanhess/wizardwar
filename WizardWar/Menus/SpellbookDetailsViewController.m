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
#import "SpellbookService.h"
#import "NSArray+Functional.h"
#import "SpellbookInteractionCell.h"
#import "UIImage+MonoImage.h"
#import "AnalyticsService.h"

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

@interface OtherInteraction : NSObject
@property (nonatomic, strong) NSString * otherSpell;
@property (nonatomic, strong) NSMutableArray * interactions;
@end
@implementation OtherInteraction
@end



@interface SpellbookDetailsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * otherInteractions;
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
    [AnalyticsService event:@"spellbook-details"];
    [AnalyticsService event:[NSString stringWithFormat:@"spellbook-details-%@", self.record.type]];
    
    self.title = self.record.name;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = [ComicZineDoubleLabel titleView:self.title navigationBar:self.navigationController.navigationBar];
    
    // the interactions are doubled up. We want to group by opposing spell
    NSArray * rawInteractions = [SpellEffectService.shared interactionsForSpell:self.record.type];
    
    NSArray * withoutNones = [rawInteractions filter:^BOOL(SpellInteraction * interaction) {
        return ![interaction.effect isKindOfClass:[SENone class]];
    }];

    NSMutableDictionary * byOtherSpell = [NSMutableDictionary dictionary];
    [withoutNones forEach:^(SpellInteraction * interaction) {
        NSString * otherSpellType;
        if ([self.record.type isEqualToString:interaction.spell])
            otherSpellType = interaction.otherSpell;
        else
            otherSpellType = interaction.spell;
        
//        NSLog(@"SAVING INTERACTION %@ %@ >> %@ %@", interaction.spell, interaction.otherSpell, otherSpellType, interaction.effect);
        
        OtherInteraction * otherInteraction = byOtherSpell[otherSpellType];
        if (!otherInteraction) {
            otherInteraction = [OtherInteraction new];
            otherInteraction.otherSpell = otherSpellType;
            otherInteraction.interactions = [NSMutableArray array];
            byOtherSpell[otherSpellType] = otherInteraction;
        }
        
        [otherInteraction.interactions addObject:interaction];
    }];
    
    self.otherInteractions = [byOtherSpell allValues];
    
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
    else if (section == SECTION_INTERACTIONS) return self.otherInteractions.count;
    else return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTION_INFO) return @"Info";
//    else if (section == SECTION_STATS) return @"Stats";
//    else if (section == SECTION_EFFECT) return @"Effect";
    if (section == SECTION_INTERACTIONS && self.otherInteractions.count) return @"Interacts With";
    else return nil;
}

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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        infoView = cell.contentView.subviews[0];
    }
    
    infoView.record = self.record;

    return cell;
}

- (UITableViewCell *)statsCell:(UITableView*)tableView
{
    static NSString *CellIdentifier = @"SpellbookStatsCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryView = [[SpellbookProgressView alloc] initWithFrame:CGRectMake(220, 0, 100, 44)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
    }
    
    SpellbookProgressView * progressView = (SpellbookProgressView*)cell.accessoryView;
    progressView.record = self.record;
    cell.textLabel.text = [NSString stringWithFormat:@"Used in %i Matches", self.record.castMatchesTotal];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Cast %i times total", self.record.castTotal];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView*)tableView effectCellForIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0) {
        return [self tableView:tableView descriptionCell:self.spellDescription];
    } else {
        EffectStat * stat = [self.effectStats objectAtIndex:indexPath.row-1];
        return [self tableView:tableView statCellWithKey:stat.name value:stat.value];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView interactionCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SpellbookInteractionCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SpellbookInteractionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = self.descriptionFont;
    }
    
    OtherInteraction * otherInteraction = [self.otherInteractions objectAtIndex:indexPath.row];
    SpellRecord * record = [SpellbookService.shared recordByType:otherInteraction.otherSpell];
    cell.imageView.image = [SpellbookService.shared spellbookIcon:record];

    NSMutableString * infoString = [NSMutableString string];
    
    if (record.isUnlocked) {
        cell.textLabel.textColor = [UIColor darkTextColor];
        for (SpellInteraction * interaction in otherInteraction.interactions) {
            Spell * spell = [Spell fromType:interaction.spell];
            [infoString appendFormat:@"%@\n", [interaction.effect describe:spell.name]];
        }
    } else {
        if (record.isDiscovered)
            [infoString appendString:record.name];
        
        [infoString appendString:@" ?"];
        cell.textLabel.textColor = [UIColor grayColor];
    }
    
    cell.textLabel.text = infoString;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView statCellWithKey:(NSString*)key value:(NSInteger)value {
    static NSString *CellIdentifier = @"SpellbookStatCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
    }
    cell.textLabel.text = description;
    return cell;
}

- (NSString*)spellDescription {
    return self.record.info.explanation;
}

- (UIFont*)descriptionFont {
    return [UIFont fontWithName:@"Helvetica" size:17.0];
}


- (CGFloat)heightForDescription:(NSString*)description {
    CGSize constraintSize = CGSizeMake(self.view.frame.size.width-20, MAXFLOAT);
    CGSize labelSize = [description sizeWithFont:self.descriptionFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 20;
}


//-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    if (section == 0 && ![UserFriendService.shared isAuthenticatedFacebook]) {
//        return @"Connect to play with your friends and set your avatar. Will not post anything unless you explitly share something.";
//    }
//    return nil;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_INFO) return self.tableView.frame.size.width/2;
    if (indexPath.section == SECTION_STATS) return 54;
    if (indexPath.section == SECTION_EFFECT) {
        if (indexPath.row == 0) return [self heightForDescription:self.spellDescription];
    }
    if (indexPath.section == SECTION_INTERACTIONS) return 54;
//    else if (indexPath.section == SECTION_EFFECT) {
//        if (indexPath.row == 1 && self.spell.damage == 0) return 0;
//        if (indexPath.row == 2 && self.spell.speed == 0) return 0;
//    }
//    else if (indexPath.section == SECTION_CAST) return SPELLBOOK_DIAGRAM_HEIGHT;
    return 44;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == SECTION_INTERACTIONS) {
        OtherInteraction * otherInteraction = [self.otherInteractions objectAtIndex:indexPath.row];
        SpellRecord * record = [SpellbookService.shared recordByType:otherInteraction.otherSpell];
        
        if (record.isUnlocked) {
            SpellbookDetailsViewController * details = [SpellbookDetailsViewController new];
            details.record = record;
            [self.navigationController pushViewController:details animated:YES];
        }

        else {
            UIAlertView * alert = [SpellbookService.shared failAlertForRecord:record];
            [alert show];
        }        
    } else if (indexPath.section == SECTION_STATS) {
        NSString * title = [SpellbookService.shared levelString:self.record.level];
        SpellbookLevel nextLevel = self.record.level+1;
        if (nextLevel <= SpellbookLevelMaster) {
            if (nextLevel < SpellbookLevelAdept) nextLevel = SpellbookLevelAdept;
            NSString * message = [NSString stringWithFormat:@"Cast in %i matches to become a %@", [self.record targetForLevel:nextLevel], [SpellbookService.shared levelString:nextLevel]];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
