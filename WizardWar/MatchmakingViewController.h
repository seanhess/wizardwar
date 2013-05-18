//
//  MatchmakingViewController.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import "MatchmakingTableViewController.h"

@interface MatchmakingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Firebase* firebaseLobby;
@property (nonatomic, strong) Firebase* firebaseInvites;
@property (nonatomic, strong) Firebase* firebaseMatches;
@property (nonatomic, strong) MatchmakingTableViewController* matchesTableViewController;
@property (nonatomic, strong) NSMutableArray* users;
@property (nonatomic, strong) NSMutableArray* invites;
@property (nonatomic, strong) NSString* nickname;
@property (nonatomic, strong) NSString* matchID;
@property (nonatomic) BOOL isInMatch;

@end
