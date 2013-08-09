//
//  UserCell.m
//  WizardWar
//
//  Created by Sean Hess on 7/8/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "UserCell.h"
#import "LocationService.h"
#import "ChallengeService.h"
#import "UIColor+Hex.h"
#import "NSString+FontAwesome.h"
#import "AppStyle.h"
#import "FacebookUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserFriendService.h"

// https://graph.facebook.com/644505774/picture?width=640&height=640

@interface UserCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@end

@implementation UserCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    self.typeLabel.font = [UIFont fontWithName:@"FontAwesome" size:20.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(User *)user {
    _user = user;
    
    NSString * name = user.name;
    if (user.facebookUser) {
//        BOOL nameContainsFirstName = ([name.lowercaseString rangeOfString:user.facebookUser.firstName.lowercaseString].length > 0);
//        BOOL nameContainsLastName = ([name.lowercaseString rangeOfString:user.facebookUser.lastName.lowercaseString].length > 0);
//        
//        if (!nameContainsFirstName || !nameContainsLastName) {
//            NSString * firstName = (nameContainsFirstName) ? @"" : user.facebookUser.firstName;
//            NSString * lastName = (nameContainsLastName) ? @"" : user.facebookUser.lastName;
//        }
        name = [NSString stringWithFormat:@"%@ (%@ %@)", name, user.facebookUser.firstName, user.facebookUser.lastName];
    }
    self.nameLabel.text = name;
    
    if (user.isOnline)
        self.nameLabel.textColor = [AppStyle greenOnlineColor];
    else
        self.nameLabel.textColor = [UIColor darkTextColor];
    
    CGSize size = self.avatarImageView.frame.size;
    NSURL * imageUrl = [UserFriendService.shared user:user facebookAvatarURLWithSize:size];
    [self.avatarImageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"user.jpg"]];

    if (user.isFacebookFriend)
        self.typeLabel.text = [NSString stringFromAwesomeIcon:FAIconFacebookSign];
    else if (user.isFrenemy)
        self.typeLabel.text = [NSString stringFromAwesomeIcon:FAIconUser];
    else
        self.typeLabel.text = [NSString stringFromAwesomeIcon:FAIconGlobe];
    
    // DISTANCE
    NSString * distance = @"";
    if (user.isOnline && user.distance >= 0) {
        distance = [LocationService.shared distanceString:user.distance];
    }
    self.distanceLabel.text = distance;
    
    Challenge * challenge = nil;
    
    if (user.activeMatchId) {
        challenge = [ChallengeService.shared challengeWithId:user.activeMatchId create:NO];
        // If challenge is nil, don't worry about it for now, I never really clear it.
        // I should probably use ... I don't know.
//        if (!challenge)
//            NSLog(@"!!! NO CHALLENGE %@", user.activeMatchId);
    }
    
    // STATUS
    if (challenge) {
        User * opponent = [challenge findOpponent:user];
        self.statusLabel.text = [NSString stringWithFormat:@"FIGHTING %@!", opponent.name];
        self.statusLabel.textColor = [UIColor darkGrayColor];
    }

    // WINS
    else {
        
        if (user.gamesTotal > 0) {
            self.statusLabel.text = [NSString stringWithFormat:@"%i/%i Wins", user.gamesWins, user.gamesTotal];
            if (user.gamesWins > user.gamesTotal/2) {
                self.statusLabel.textColor = [AppStyle greenGrassColor];
            } else {
                self.statusLabel.textColor = [UIColor redColor];
            }
        } else {
            self.statusLabel.text = @"";
        }
        
        
        
    }
}

-(void)reloadFromUser {
    self.user = self.user;
}

@end
