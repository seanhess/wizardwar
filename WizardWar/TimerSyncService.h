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
@protocol TimerSyncDelegate
-(void)gameShouldStartAt:(NSTimeInterval)startTime;
@end

@interface TimerSyncService : NSObject
@property (nonatomic, weak) id<TimerSyncDelegate> delegate;
+(TimerSyncService*)shared;
-(void)update:(NSTimeInterval)delta;
-(void)syncTimerWithMatchId:(NSString*)matchId player:(Wizard*)player isHost:(BOOL)isHost;
-(void)disconnect;
@end
