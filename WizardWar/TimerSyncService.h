//
//  TimerSyncService.h
//  WizardWar
//
//  Created by Sean Hess on 5/29/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Wizard.h"
@protocol TimerSyncDelegate
-(void)gameShouldStartAt:(NSTimeInterval)startTime;
@end

@interface TimerSyncService : NSObject
@property (nonatomic, weak) id<TimerSyncDelegate> delegate;
-(void)syncTimerWithMatchId:(NSString*)matchId player:(Wizard*)player isHost:(BOOL)isHost;
-(void)disconnect;
@end
