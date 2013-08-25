//
//  WarningCell.h
//  WizardWar
//
//  Created by Sean Hess on 8/16/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BButton.h>
#import "User.h"

@interface WarningCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet BButton *button;
@property (weak, nonatomic) IBOutlet UITextView *textView;

-(void)setWarningText:(NSString*)text;
-(void)setUserInfo:(User*)user;
@end
