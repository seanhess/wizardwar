//
//  ProfileCell.h
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileCell : UITableViewCell
@property (nonatomic, strong) User * user;
+(NSString*)identifier;
+(CGFloat)height;
@end
