//
//  ChallengeCell.m
//  WizardWar
//
//  Created by Sean Hess on 7/10/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "ChallengeCell.h"
#import "UserService.h"
#import "UIColor+Hex.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserFriendService.h"

@interface ChallengeCell ()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *opponentImageView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) UIImage * placeholderImage;
@end

@implementation ChallengeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

//- (void)awakeFromNib {
//    [super awakeFromNib];
//}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//}

-(void)setChallenge:(Challenge *)challenge currentUser:(User *)user {
    self.challenge = challenge;
    BOOL isCreatedByUser = [self.challenge.main.userId isEqualToString:user.userId];
    
    // Who are you fighting against?
    User * opponent = [self.challenge findOpponent:user];
    self.mainLabel.text = [NSString stringWithFormat:@"WAR vs %@", opponent.name];
    
    
    if (!self.placeholderImage) {
        self.placeholderImage = [UIImage imageNamed:@"user.jpg"];
    }
    CGSize size = self.mainImageView.frame.size;
    NSURL * mainImageURL = [UserFriendService.shared user:challenge.main facebookAvatarURLWithSize:size];
    [self.mainImageView setImageWithURL:mainImageURL placeholderImage:self.placeholderImage];
    NSURL * opponentImageURL = [UserFriendService.shared user:challenge.opponent facebookAvatarURLWithSize:size];
    [self.opponentImageView setImageWithURL:opponentImageURL placeholderImage:self.placeholderImage];
    
    
    // default state is stopped
    [self.activityView stopAnimating];
    
    if (challenge.status == ChallengeStatusDeclined) {
        self.otherLabel.text = [NSString stringWithFormat:@"%@ Ran Away!", opponent.name];
        self.backgroundView.backgroundColor = [UIColor colorFromRGB:0xE75759];
        // TODO show declined state. Change background to red?
    }
    
    else if (challenge.status == ChallengeStatusAccepted) {
        self.otherLabel.text = @"Accepted!";
        self.backgroundView.backgroundColor = [UIColor colorFromRGB:0xA4E88F];
    }
    
    else {
        // I am main
        if (isCreatedByUser) {
            [self.activityView startAnimating];
            self.otherLabel.text = [NSString stringWithFormat:@"Waiting for them to accept..."];
            self.backgroundView.backgroundColor = [UIColor colorFromRGB:0xE6F1FE];
        }
        
        // Ready to play!
        else {
            self.otherLabel.text = [NSString stringWithFormat:@"Tap to play!"];
            self.backgroundView.backgroundColor = [UIColor colorFromRGB:0xA4E88F];
        }        
    }
    
}

@end
