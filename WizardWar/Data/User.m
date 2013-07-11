//
//  User.m
//  WizardWar
//
//  Created by Sean Hess on 7/8/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "User.h"


@implementation User

@dynamic deviceToken;
@dynamic isOnline;
@dynamic locationLatitude;
@dynamic locationLongitude;
@dynamic name;
@dynamic userId;
@dynamic friendPoints;
@dynamic distance;
@dynamic challenge;
@dynamic updated;
@dynamic activeMatchId;

@synthesize isClose;

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"name", @"userId", @"deviceToken"]];
};

-(NSDictionary*)toLobbyObject {
    return [self dictionaryWithValuesForKeys:@[@"locationLatitude", @"locationLongitude", @"activeMatchId"]];
}

//- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues {
//    NSMutableDictionary * values = [NSMutableDictionary dictionaryWithDictionary:keyedValues];
//    [super setValuesForKeysWithDictionary:values];
//}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ name:%@ count:%i", super.description, self.name, self.friendPoints];
}

- (CLLocation *)location {
    if (!self.locationLatitude || !self.locationLongitude) return nil;
    return [[CLLocation alloc] initWithLatitude:self.locationLatitude longitude:self.locationLongitude];
}

- (BOOL)isFriend {
    return self.friendPoints > 0;
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
