//
//  TutorialStep.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

#define TSAdvanceTap ^(TutorialStep*step) { step.advanceOnTap = YES; }
#define TSAdvanceDamage ^(TutorialStep*step) { step.advanceOnDamage = YES; }
#define TSAdvanceSpell(SpellType) (^(TutorialStep*step) { step.advanceOnSpell = SpellType; })
#define TSAdvanceSpellAny ^(TutorialStep*step) { step.advanceOnAnySpell = YES; }


@class TutorialStep;

typedef void(^TutorialStepConfig)(TutorialStep*);

// These only matter for TUTORIALS, the other bad guys won't need this much stuff
// it's not like they're going to step through, they can change their algorithm some other way

@interface TutorialStep : NSObject
@property (nonatomic, strong) NSString * message;
@property (nonatomic) BOOL hideControls; // default is NO
@property (nonatomic) BOOL disableControls; // default is NO
@property (nonatomic, strong) NSArray * allowedSpells; // default is nil

@property (nonatomic, strong) NSArray * tactics;

@property (nonatomic) BOOL advanceOnTap;
@property (nonatomic, strong) NSString * advanceOnSpell;
@property (nonatomic) BOOL advanceOnAnySpell;
@property (nonatomic) BOOL advanceOnDamage;


// given the state of the game, should we advance
//@property (nonatomic, strong) advanceOn shouldAdvance;
//@property (nonatomic, strong) aiAlgorithm asdlksdlkj;

// a simple advance-on-tap message step
+(id)modalMessage:(NSString*)message;
+(id)message:(NSString*)message hideControls:(BOOL)hideControls;
+(id)message:(NSString*)message disableControls:(BOOL)disableControls;
+(id)message:(NSString*)message; // unlocked messaged
+(id)message:(NSString*)message tactics:(NSArray*)tactics advance:(TutorialStepConfig)action allowedSpells:(NSArray*)allowed;

@end







