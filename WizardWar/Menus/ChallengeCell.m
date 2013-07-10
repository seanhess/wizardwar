//
//  ChallengeCell.m
//  WizardWar
//
//  Created by Sean Hess on 7/10/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "ChallengeCell.h"
#import "UserService.h"

@interface ChallengeCell ()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *opponentImageView;

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
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
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setChallenge:(Challenge *)challenge currentUser:(User *)user {
    self.challenge = challenge;
    
    User * opponent = nil;
    
    // default state is stopped
    [self.activityView stopAnimating];
    
    // I am main
    if ([self.challenge.main.userId isEqualToString:user.userId]) {
        opponent = self.challenge.opponent;
        

        if (challenge.status == ChallengeStatusPending) {
            [self.activityView startAnimating];
            self.otherLabel.text = [NSString stringWithFormat:@"Waiting for them to accept..."];
        }
        else if (challenge.status == ChallengeStatusDeclined) {
            self.otherLabel.text = @"Declined!";
            // TODO show declined state. Change background to red?
        }
    }
    else {
        opponent = self.challenge.main;
        self.otherLabel.text = [NSString stringWithFormat:@"Tap to play!"];
    }
    
    
    self.mainLabel.text = [NSString stringWithFormat:@"WAR vs %@", opponent.name];
    


}

@end
