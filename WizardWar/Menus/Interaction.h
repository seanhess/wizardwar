//
//  Interaction.h
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Interaction : NSObject
@property (strong, nonatomic) NSString * interactionId;
@property (strong, nonatomic) User * user; // only has basic user info
@property (strong, nonatomic) NSString * text; // so you can use this for chat
@end
