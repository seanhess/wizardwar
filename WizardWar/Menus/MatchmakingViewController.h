//
//  MatchmakingViewController.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface MatchmakingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Firebase* firebaseLobby;
@property (nonatomic, strong) Firebase* firebaseInvites;
@property (nonatomic, strong) UITableViewController * matchesTableViewController;
@property (nonatomic, strong) NSString* nickname;
@property (nonatomic, strong) NSString* matchID;

@property (nonatomic, strong) NSString* autoconnectToMatchId;

//-(void)disconnect;
//-(void)reconnect;

@end
