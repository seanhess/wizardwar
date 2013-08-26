//
//  FacebookButtonCell.h
//  WizardWar
//
//  Created by Sean Hess on 7/19/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface SettingsFacebookButtonCell : UITableViewCell
@property (nonatomic) BOOL waiting;
@property (nonatomic) NSString * title;
-(id)initWithReuseIdentifier:(NSString*)reuseIdentifier;
@end
