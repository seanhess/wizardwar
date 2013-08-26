//
//  User.m
//  WizardWar
//
//  Created by Sean Hess on 7/8/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "User.h"
#import "UIColor+Hex.h"

@implementation User

@dynamic deviceToken;
@dynamic isOnline;
@dynamic locationLatitude;
@dynamic locationLongitude;
@dynamic name;
@dynamic userId;
@dynamic gamesTotal;
@dynamic gamesWins;
@dynamic distance;
@dynamic challenge;
@dynamic updated;
@dynamic joined;
@dynamic activeMatchId;
@dynamic colorRGB;
@dynamic isMain;
@dynamic facebookId;
@dynamic facebookUser;
@dynamic version;
@dynamic wizardLevel;
@dynamic questLevel;

@synthesize isClose;
@synthesize isGuestAccount;

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"name", @"userId", @"deviceToken", @"colorRGB", @"facebookId"]];
};

-(NSDictionary*)toLobbyObject {
    return [self dictionaryWithValuesForKeys:@[@"locationLatitude", @"locationLongitude", @"activeMatchId", @"version", @"wizardLevel"]];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ name:%@ count:%i", super.description, self.name, self.gamesTotal];
}

- (CLLocation *)location {
    if (!self.locationLatitude || !self.locationLongitude) return nil;
    return [[CLLocation alloc] initWithLatitude:self.locationLatitude longitude:self.locationLongitude];
}

- (BOOL)isFrenemy {
    return self.gamesTotal > 0;
}

-(BOOL)isFacebookFriend {
    return (self.facebookUser != nil);
}

- (UIColor*)color {
    return [UIColor colorFromRGB:self.colorRGB];
}

- (void)setColor:(UIColor *)color {
    self.colorRGB = color.RGB;
}

-(id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    return;
}

- (NSInteger)gamesLosses {
    return self.gamesTotal - self.gamesWins;
}

- (CGFloat)masteryProgress {
    // should be overall wins/losses
    return ((float)self.gamesWins / (float)self.masteryWins);
}

- (NSInteger)masteryWins {
    return (2*self.gamesLosses+2);
}

- (BOOL)isMastered {
    // mastery = 2 * the number of losses + 2
    return self.gamesWins >= self.masteryWins;
}


//- (void)encodeWithCoder:(NSCoder *)encoder {
//    [encoder encodeObject:self.name forKey:@"name"];
//    [encoder encodeObject:self.userId forKey:@"userId"];
//    [encoder encodeObject:@(self.friendCount) forKey:@"friendCount"];
//    [encoder encodeObject:self.deviceToken forKey:@"deviceToken"];
//}
//
//- (id)initWithCoder:(NSCoder *)decoder {
//    if((self = [super init])) {
//        self.name = [decoder decodeObjectForKey:@"name"];
//        self.userId = [decoder decodeObjectForKey:@"userId"];
//        self.friendCount = [[decoder decodeObjectForKey:@"friendCount"] intValue];
//        self.deviceToken = [decoder decodeObjectForKey:@"deviceToken"];
//    }
//    return self;
//}

@end
