//
//  SpellbookCell.h
//  WizardWar
//
//  Created by Sean Hess on 8/19/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpellRecord.h"

@interface SpellbookCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

-(void)setSpellRecord:(SpellRecord*)record;
+(NSString*)spellTitle:(SpellRecord*)record;
@end
