//
//  Challenge.h
//  WizardWar
//
//  Created by Sean Hess on 7/10/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Objectable.h"
#import "User.h"

@interface Challenge : NSManagedObject <Objectable>

@property (nonatomic) BOOL accepted;

@property (nonatomic, retain) User *main;
@property (nonatomic, retain) User *opponent;

@property (nonatomic, strong) NSString * mainId;
@property (nonatomic, strong) NSString * opponentId;

-(NSString*)matchId;

@end
