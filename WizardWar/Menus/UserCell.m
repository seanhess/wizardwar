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
#import "LobbyService.h"
#import "UIColor+Hex.h"
#import "NSString+FontAwesome.h"
#import "AppStyle.h"
#import "FacebookUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserFriendService.h"
#import <ReactiveCocoa.h>
#import "ProgressAccessoryView.h"
#import <BButton.h>


// https://graph.facebook.com/644505774/picture?width=640&height=640

@interface UserCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusIconLabel;
@property (weak, nonatomic) IBOutlet ProgressAccessoryView *progressVIew;
@property (nonatomic) CGRect topNameLabelFrame;
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
    self.facebookIconLabel.font = [UIFont fontWithName:@"FontAwesome" size:self.facebookIconLabel.font.pointSize];
    self.facebookIconLabel.text = [NSString stringFromAwesomeIcon:FAIconFacebook];
    self.facebookIconLabel.textColor = [UIColor colorWithRed:0.23f green:0.35f blue:0.60f alpha:1.00f];
    
    self.statusIconLabel.font = [UIFont fontWithName:@"FontAwesome" size:self.statusLabel.font.pointSize];
    self.statusIconLabel.text = [NSString stringFromAwesomeIcon:FAIconGlobe];
    
    self.topNameLabelFrame = self.nameLabel.frame;
    
    __weak UserCell * wself = self;
    [RACAble(LobbyService.shared, currentServerTime) subscribeNext:^(id x) {
        [wself renderTimeAndDistance:wself.user];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUser:(User *)user {
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
    
    self.facebookIconLabel.hidden = (!user.isFacebookFriend);
    
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
    } else {
        [self renderTimeAndDistance:user];
    }
    
    // WINS
    // Progress: 
    ProgressAccessoryView * progress = self.progressVIew;
    progress.hidden = (user.gamesTotal == 0);
    progress.progressView.progress = user.masteryProgress;
    NSString * winLossRatio = [NSString stringWithFormat:@"%i:%i", user.gamesWins, user.gamesLosses];
    
    if (user.isMastered) {
        progress.progressColor = [AppStyle greenOnlineColor];
        progress.label.textColor = [UIColor whiteColor];
        progress.alignCenter = YES;
        progress.label.text = @"MASTER"; // [NSString stringWithFormat:@"MASTER %@", winLossRatio];
    }

    else {
        progress.progressColor = [AppStyle blueNavColor];
        progress.label.textColor = [AppStyle blueNavColor];
        progress.label.text = [NSString stringWithFormat:@"Won %@", winLossRatio];
        progress.alignCenter = NO;
    }
    
    if (user.gamesWins < user.foolWins) {
        progress.progressColor = [AppStyle redErrorColor];
        progress.label.textColor = [AppStyle redErrorColor];
    }
    
//    if (user.gamesTotal > 0) {
//        self.statusLabel.text = [NSString stringWithFormat:@"%i/%i Wins", user.gamesWins, user.gamesTotal];
//        if (user.gamesWins > user.gamesTotal/2) {
//            self.statusLabel.textColor = [AppStyle greenGrassColor];
//        } else {
//            self.statusLabel.textColor = [UIColor redColor];
//        }
//    }
    
}

-(void)renderTimeAndDistance:(User*)user {
    if (!user) return;
    
    NSMutableString * status = [NSMutableString string];
    
    status = [NSMutableString stringWithFormat:@"Level %i", user.wizardLevel];
    
    if (user.isOnline && user.distance >= 0) {
        NSString * distance = [LocationService.shared distanceString:user.distance];
//        self.statusLabel.text = distance;
        [status appendFormat:@" - %@", distance];
    }
    
    else {
        self.statusLabel.text = @"";
    }
    
    
    self.statusLabel.text = status;
}

-(void)reloadFromUser {
    [self setUser:self.user];
}

@end
