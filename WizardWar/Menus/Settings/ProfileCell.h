//
//  ProfileCell.h
//  WizardWar
//
//  Created by Sean Hess on 7/19/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString*)cellIdentifier;
-(void)setUserName:(User*)user;
-(void)setUserColor:(User*)user;

@end
