//
//  ProfileCell.m
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.


#import "ProfileCell.h"
#import "UserFriendService.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppStyle.h"

@interface ProfileCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@end

@implementation ProfileCell

- (void)awakeFromNib {
//    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.contentView.backgroundColor = [AppStyle blueMessageColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUser:(User*)user {
    self.nameLabel.text = user.name;
    self.levelLabel.text = [NSString stringWithFormat:@"Level %i", user.wizardLevel];
    
    CGSize size = self.avatarImageView.frame.size;
    NSURL * imageUrl = [UserFriendService.shared user:user facebookAvatarURLWithSize:size];
    [self.avatarImageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"user.jpg"]];
    
}

+(CGFloat)height {
    return 54;
}

+(NSString*)identifier {
    return NSStringFromClass(self);
}


@end
