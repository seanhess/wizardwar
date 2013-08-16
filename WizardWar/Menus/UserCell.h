//
//  UserCell.h
//  WizardWar
//
//  Created by Sean Hess on 7/8/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserCell : UITableViewCell

@property (nonatomic, strong) User * currentUser;
@property (nonatomic, strong) User * user;
-(void)reloadFromUser;
-(void)setUser:(User *)user currentUser:(User*)currentUser;
@end
