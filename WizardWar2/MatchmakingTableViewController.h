//
//  MatchmakingTableViewController.h
//  WizardWar
//
//  Created by Clay Ferris on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface MatchmakingTableViewController : UITableViewController

@property (nonatomic, strong) Firebase* firebaseLobby;
@property (nonatomic, strong) Firebase* firebaseInvites;
@property (nonatomic, strong) NSMutableArray* users;
@property (nonatomic, strong) NSMutableArray* invites;
@property (nonatomic, strong) NSString* nickname;

@end
