//
//  Achievement.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "Achievement.h"

@implementation Achievement
+(id)wizardLevel:(User*)user {
    return [Achievement new];
}

+(id)spellLevel:(SpellRecord*)record {
    return [Achievement new];
}

+(id)questMastered:(QuestLevel*)level {
    return [Achievement new];
}

@end
