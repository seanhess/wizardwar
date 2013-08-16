//
//  TimerSyncService.h
//  WizardWar
//
//  Created by Sean Hess on 5/29/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

// NOTE: There is no way you should EVER connect to more than one match at a time.
// make this global to error check for you
// you MUST remember to call disconnect!

#import <Foundation/Foundation.h>
#import "Wizard.h"
#import "GameTimerService.h"
#import <Firebase/Firebase.h>
@protocol TimerSyncDelegate
-(void)gameIsSynchronized;
@end

@interface TimerSyncService : NSObject
@property (nonatomic, weak) id<TimerSyncDelegate> delegate;
@property (nonatomic, strong) Firebase * root;
+(TimerSyncService*)shared;
-(void)syncTimerWithMatchId:(NSString*)matchId player:(Wizard*)player isHost:(BOOL)isHost timer:(GameTimerService*)timer;
-(void)disconnect;
@end
