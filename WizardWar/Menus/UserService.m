//
//  UserFriendService.m
//  WizardWar
//
//  Created by Sean Hess on 6/21/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "UserService.h"
#import <Firebase/Firebase.h>
#import "IdService.h"
#import <CoreData/CoreData.h>
#import "ObjectStore.h"
#import "NSArray+Functional.h"
#import "AnalyticsService.h"

@interface UserService ()
@property (nonatomic, strong) FQuery * query;
@property (nonatomic, strong) Firebase * node;
@property (nonatomic, strong) NSString * deviceToken;
@property (nonatomic, strong) NSString * entityName;
@property (nonatomic) NSTimeInterval lastUpdatedTime;
@property (nonatomic, strong) NSArray * randomNames;
@property (nonatomic) BOOL userNeedsSave;
@end

@implementation UserService

+ (UserService *)shared {
    static UserService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserService alloc] init];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        self.entityName = @"User";
        self.randomNames = @[@"Actrise",@"Adwen",@"Aeres",@"Aethwy",@"Aigneis",@"Ailios",@"Aine",@"Aiwendil",@"Akashik",@"Akthuri",@"Alasdair",@"Alatar",@"Alcwyn",@"Aled",@"Allanon",@"Alwena",@"Alwyn",@"Animagus",@"Aradia ",@"Arddun",@"Arfonia",@"Ariannell",@"Artro",@"Arwyn",@"Ashley",@"Asquith",@"Aulë",@"Aurddolen",@"Aylith",@"Baba Yaga ",@"Ballimore",@"Banwen",@"Barabel",@"Basilisk",@"Beathag",@"Bechan",@"Belgarath",@"Berwyn",@"Bethan",@"Betrys",@"Betsan",@"Bigby",@"Blodwen",@"Blodeuwedd",@"Bloodwynd",@"Bochanan",@"Boggart ",@"Braint",@"Branwen",@"Briallen",@"Brighde",@"Bronmai",@"Brychan",@"Brynach",@"Cackletta",@"Cadell",@"Cairistiona",@"Calum",@"Caoilfhionn",@"Carwen",@"Caswallon",@"Cathal",@"Caxton",@"Ceidio",@"Ceindeg",@"Ceinlys",@"Ceiriog",@"Ceit",@"Celynen",@"Cerian",@"Ceridwen",@"Chrestomanci ",@"Chun",@"Ciaran",@"Circe ",@"Cormac",@"Crispinophur",@"Crisdean",@"Crisiant",@"Curumo",@"Daibhidh",@"Dakin",@"Dalamar",@"Dervla",@"Dewi",@"Doileag",@"Doilidh",@"Donaidh",@"Dormammu",@"Drawmij",@"Dughall",@"Dulais",@"Dyfi",@"Dyfynnog",@"Dyfyr",@"Eachann",@"Eanraig",@"Edern",@"Eidin",@"Eifiona",@"Eira",@"Elenid",@"Elfryn",@"Elric",@"Endora",@"Eruiona",@"Esmeralda",@"Eurfron",@"Eulfwyn",@"Euthanatos",@"Evard",@"Fachtna",@"Fearchar",@"Ffagan",@"Ffiniam",@"Fflur",@"Fionnghal",@"Fistandantilus ",@"Fizban",@"Floraidh",@"Freyja",@"Galadriel",@"Gandalf",@"Gandolf",@"Garmon",@"Gearroid",@"Ged",@"Gilfaethwy",@"Glinda",@"Goewyn",@"Greum",@"Griffri",@"Gruntilda",@"Gwalia",@"Gwaun",@"Gwener",@"Gwenddydd",@"Gwenfrewi",@"Gwenllian",@"Gwenogfryn",@"Gwentor",@"Gwladys",@"Gytha",@"Hecate ",@"Hefeydd",@"Hermione",@"Hexuba",@"Hirael",@"Hiraethog",@"Hiral",@"Hirwen",@"Huwcyn",@"Ionor",@"Ionwen",@"Iorwen",@"Iseabail",@"Jadis",@"Jervis",@"Karavelia",@"Keredwel",@"Kirfenia",@"Lachlann",@"Leitis",@"Leomund",@"Leri",@"Lilith ",@"Llyr",@"Llywela",@"Loki",@"Lynfa",@"Lynwen",@"Mabli",@"Maedbh",@"Maelor",@"Magaidh",@"Magius",@"Mairead",@"Mairwen",@"Majella",@"Maldue",@"Malvina",@"Mandrake",@"Manwë",@"Maoilios",@"Mararad",@"Mared",@"Mata",@"Mazara",@"Meduwen",@"Medwen",@"Mefin",@"Meic",@"Meinir",@"Meinwen",@"Melf",@"Menw ",@"Merlin ",@"Merlyn",@"Milamber",@"Mondain",@"Mor",@"Morag",@"Mordenkainen",@"Mordo",@"Morgon",@"Morinohtar",@"Morwen",@"Murchadh",@"Myfanwy",@"Nantlais",@"Nefydd",@"Neifion",@"Nerys",@"Niall",@"Nidian",@"Ningauble",@"Nisien",@"Noirin",@"Nystul",@"Ogion",@"Ogun",@"Oighrig",@"Olórin",@"Onllwyn",@"Oromë ",@"Oschwy",@"Otiluke",@"Padraig",@"Palin Majere",@"Pallando",@"Par-Salian",@"Peigi ",@"Pennar",@"Peredur",@"Powys",@"Radagast",@"Rainillt",@"Raonaid",@"Rary",@"Ravenclaw",@"Rhiain",@"Rhialto",@"Rhianedd",@"Rhianwen",@"Rhianydd",@"Rhoslyn",@"Rincewind ",@"Roisin",@"Romestamo",@"Ruairidh",@"Sagwora",@"Saoirse",@"Sargon",@"Saruman",@"Searlait",@"Seasaidh",@"Seisyllt",@"Seonag",@"Serafina",@"Seren",@"Shazam",@"Sheelba",@"Siencyn",@"Sileas",@"Siusaidh",@"Siwan",@"Slytherin",@"Sorcha",@"Sparrowhawk",@"Squib",@"Stiubhart",@"Sulwen",@"Talfan",@"Tangwystl",@"Tasha",@"Tearlach",@"Tegeirian",@"Tenser",@"Thothamon",@"Torcuil",@"Tormod",@"Tsotha-lanti ",@"Uilleam",@"Varda",@"Wanda",@"Wetzel",@"Xanadu",@"Yara",@"Yavanna",@"Yaztromo",@"Zatanna",@"Zatara",@"Zeddicus",@"Zorander ",@"Zu'l"];
    }
    return self;
}

-(BOOL)isConnected {
    return (self.query != nil);
}

- (void)connect:(Firebase*)root {
    self.node = [root childByAppendingPath:@"users"];
    
    self.lastUpdatedTime = [self loadLastUpdatedTime];
    NSNumber * timeInMilliseconds = @(self.lastUpdatedTime*1000);
    NSLog(@"UserService: lastUpdatedTime:%@", timeInMilliseconds);
    
    FQuery * query = [self.node queryStartingAtPriority:timeInMilliseconds]; // in milliseconds
    
    __weak UserService * wself = self;

    [query observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [query observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [wself onRemoved:snapshot];
    }];
    
    [query observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [wself onChanged:snapshot];
    }];
    
    self.query = query;
    
    if (self.userNeedsSave) {
        [self saveCurrentUser];
        self.userNeedsSave = NO;
    }
}

- (void)disconnect {
    [self.query removeAllObservers];
    [self.node removeAllObservers];
    self.node = nil;
    self.query = nil;
}

-(void)onAdded:(FDataSnapshot *)snapshot {
    NSString * userId = snapshot.name;
    User * user = [self userWithId:userId create:YES];
    // This does not throw an error for missing keys, because I implemented the methods in User.m
    [user setValuesForKeysWithDictionary:snapshot.value];
    user.updated = ([snapshot.priority doubleValue] / 1000.0); // comes down in milliseconds
    NSLog(@"UserService: (+) %i %@", (int)(user.updated - self.lastUpdatedTime), user.name);
    
    if ([user.deviceToken isEqualToString:self.currentUser.deviceToken] && ![user.userId isEqualToString:self.currentUser.userId]) {
        [self mergeCurrentUserWith:user];
    }
    
    self.lastUpdatedUser = user;
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    NSString * userId = snapshot.name;
    User * user = [self userWithId:userId];
    if (user) {
        NSLog(@"UserService: (-) %@", user.name);
        [ObjectStore.shared.context deleteObject:user];
    }
}

-(void)onChanged:(FDataSnapshot*)snapshot {
    [self onAdded:snapshot];
}

- (void)deleteAllData {
    self.currentUser = nil;
    NSArray * users = [ObjectStore.shared requestToArray:[self requestAllUsers]];
    [users forEach:^(User*user) {
        [ObjectStore.shared.context deleteObject:user];
    }];
}


# pragma mark - Friends




# pragma mark - DeviceToken

- (void)saveDeviceToken:(NSString *)deviceToken {
    
    [AnalyticsService event:@"DeviceToken"];
    
    // this must be before you set the device token on yours
    User * otherUserWithToken = [ObjectStore.shared requestLastObject:[self requestDeviceToken:deviceToken user:self.currentUser]];
    if (otherUserWithToken)
        [self mergeCurrentUserWith:otherUserWithToken];

    self.pushAccepted = YES;
    
    if (![self.currentUser.deviceToken isEqualToString:deviceToken]) {
        self.currentUser.deviceToken = deviceToken;
        [self saveCurrentUser];
    }
}


- (void)mergeCurrentUserWith:(User*)user {
    
    // Remove old current user
    User * oldCurrentUser = self.currentUser;

    Firebase * child = [self.node childByAppendingPath:oldCurrentUser.userId];
    [child removeValue];
    [child setPriority:kFirebaseServerValueTimestamp];
    
    // save the new one!
    self.currentUser = user;
    self.currentUser.isMain = YES;
    NSLog(@"UserService.merged %@ to %@", oldCurrentUser.userId, self.currentUser.userId);
    
    [ObjectStore.shared objectRemove:oldCurrentUser];
    
    return;
}


- (NSString*)randomWizardName {
    return [self.randomNames randomItem];
}

- (void)saveCurrentUser {
    // Save to firebase
    if (!self.isConnected) {
        self.userNeedsSave = YES;
        return;
    }
    User * user = self.currentUser;
    if (!user) return;
    Firebase * child = [self.node childByAppendingPath:user.userId];
    [child setValue:user.toObject andPriority:kFirebaseServerValueTimestamp];
}

-(NSTimeInterval)loadLastUpdatedTime {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    NSSortDescriptor * sortByLastUpdated = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
    request.sortDescriptors = @[sortByLastUpdated];
    User * user = [ObjectStore.shared requestLastObject:request];
    return user.updated;
}

- (User*)currentUser {
    if (!_currentUser) {
        User * user = [ObjectStore.shared requestLastObject:self.requestIsMain];

        if (!user) {
            user = [ObjectStore.shared insertNewObjectForEntityForName:self.entityName];
            user.userId = [self generateUserId];
            user.isMain = YES;
            user.name = [self randomWizardName]; // [NSString stringWithFormat:@"Guest%@", [IdService randomId:4]];
            user.isGuestAccount = YES;
            user.wizardLevel = 1;
//            user.questLevel = 10;
            user.color = [UIColor blackColor];
            NSLog(@"UserService.currentUser: GENERATED %@", user.userId);
        } else {
            NSLog(@"UserService.currentUser: EXISTS %@", user.userId);
        }
        
        self.currentUser = user;
    }
        
    return _currentUser;
}

- (Wizard*)currentWizard {
    // TODO, actually save this information, yo?
    Wizard * wizard = [Wizard new];
    wizard.name = self.currentUser.name;
    wizard.color = self.currentUser.color;
    if (!wizard.name) wizard.name = [NSString stringWithFormat:@"Guest%@", [IdService randomId:4]];
    wizard.wizardType = WIZARD_TYPE_ONE;
    return wizard;
}

- (BOOL)isAuthenticated {
//    return self.currentUser.name != nil;
    return !self.currentUser.isGuestAccount;
}

- (NSString*)generateUserId {
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

- (BOOL)user:(User*)user shouldUpgradeToMatch:(User*)user2 {
    NSComparisonResult result = [user.version compare:user2.version];
    return (result == NSOrderedAscending);
}


# pragma mark - Users

- (User*)userWithId:(NSString*)userId {
    return [self userWithId:userId create:NO];
}

- (User*)userWithId:(NSString*)userId create:(BOOL)create {
    NSFetchRequest * request = [self requestAllUsers];
    request.predicate = [self predicateIsUser:userId];
    User * user = [ObjectStore.shared requestLastObject:request];
    if (!user && create) {
        user = [ObjectStore.shared insertNewObjectForEntityForName:self.entityName];
        user.userId = userId;
    }
    return user;
}

- (User*)userWithPredicate:(NSPredicate*)predicate {
    NSFetchRequest * request = [self requestAllUsers];
    request.predicate = predicate;
    User * user = [ObjectStore.shared requestLastObject:request];
    return user;
}

# pragma mark - Core Data

- (NSSortDescriptor*)sortIsOnline {
    return [NSSortDescriptor sortDescriptorWithKey:@"isOnline" ascending:NO];
}

- (NSPredicate*)predicateIsUser:(NSString*)userId {
    return [NSPredicate predicateWithFormat:@"userId = %@", userId];
}

- (NSPredicate*)predicateIsOnline:(BOOL)online {
    return [NSPredicate predicateWithFormat:@"isOnline = %i", online];
}

- (NSFetchRequest*)requestAllUsers {
    // valid users include:
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"name != nil"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    return request;
}

- (NSFetchRequest*)requestAllUsersExcept:(User *)user {
    NSFetchRequest * request = [self requestAllUsers];
    NSPredicate * notUser = [NSCompoundPredicate notPredicateWithSubpredicate:[self predicateIsUser:user.userId]];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[notUser, request.predicate]];
    return request;
}

- (NSFetchRequest*)requestOtherOnline:(User *)user {
    NSFetchRequest * request = [self requestAllUsersExcept:user];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[self predicateIsOnline:YES], request.predicate]];
    return request;
}

- (NSFetchRequest*)requestIsMain {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"isMain = YES"];
    return request;
}

- (NSFetchRequest*)requestDeviceToken:(NSString*)deviceToken user:(User*)user {
    NSFetchRequest * request = [self requestAllUsersExcept:user];
    NSPredicate * matchDeviceToken = [NSPredicate predicateWithFormat:@"deviceToken = %@", deviceToken];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[matchDeviceToken, request.predicate]];
    return request;    
}

@end
