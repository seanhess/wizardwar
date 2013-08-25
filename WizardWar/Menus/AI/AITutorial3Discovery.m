//
//  AITutorial3Discovery.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITutorial3Discovery.h"
#import "AITPerfectCounter.h"

@implementation AITutorial3Discovery


-(id)init {
    if ((self = [super init])) {
        
        // TACTIC: perfect-counter the basic three spells
        
        NSDictionary * counters = @{
            Fireball : Lightning,
            Lightning : Monster,
            Monster : Fireball
        };
        
        self.steps = @[
            [TutorialStep modalMessage:@"So you want to know the secret to my greatness? Insolent fool!"],
            [TutorialStep modalMessage:@"Ok, I'll tell you anyway."],
            [TutorialStep modalMessage:@"Experiment! You don't climb to the top of the order by sitting around."],
            [TutorialStep modalMessage:@"Now I unfurl my the full might of my Wizardness!"],
            [TutorialStep modalMessage:@"The only way to beat me is to discover something new. Get ready!"],

            [TutorialStep message:nil
                             demo:nil
                          tactics:@[[AITPerfectCounter counters:counters]]
                          advance:TSAdvanceEnd
                    allowedSpells:nil],
            
            [TutorialStep win:@"I'm just going to lay here for a while" lose:@"Wahoo!"]
        ];
    }
    return self;
}
                      


@end
