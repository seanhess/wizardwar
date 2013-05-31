//  MatchViewController.m
//  WizardWar
//
//  Created by Sean Hess on 5/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//


// This class should deal EXCLUSIVELY with the interaction between
// the UIViews and the game

#import "MatchViewController.h"
#import "PentagramViewController.h"
#import "WizardDirector.h"
#import "TestLayer.h"
#import "MatchLayer.h"
#import "SimpleAudioEngine.h"
#import "Elements.h"
#import "Spell.h"
#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellVine.h"
#import "SpellWindblast.h"
#import "SpellIcewall.h"
#import "Match.h"
#import "MultiplayerService.h"
#import <ReactiveCocoa.h>
#import "TimerSyncService.h"

@interface MatchViewController () <PentagramDelegate>
@property (strong, nonatomic) IBOutlet PentagramViewController *pentagram;
@property (weak, nonatomic) IBOutlet UIView *cocosView;
@property (strong, nonatomic) Match * match;
@end

@implementation MatchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.pentagram viewDidLoad];
    self.pentagram.delegate = self;
    [self playMusic];
    
    
    // Add the director's view to us
    CCDirectorIOS * director = [WizardDirector shared];
    [self.cocosView addSubview:director.view];
    director.view.frame = self.cocosView.bounds;
    MatchLayer * matchLayer = [[MatchLayer alloc] initWithMatch:self.match size:self.cocosView.bounds.size];
    [WizardDirector runLayer:matchLayer];
    
    [self renderMatchStatus];
}

- (void)connectToMatchWithId:(NSString*)matchId currentPlayer:(Player*)player withAI:(Player*)ai {
    id<Multiplayer> multiplayer = nil;
    TimerSyncService * sync = nil;
    if (ai) { }
    else {
        multiplayer = [MultiplayerService new];
        sync = [TimerSyncService new];
    }
    [multiplayer connectToMatchId:matchId];
    self.match = [[Match alloc] initWithId:matchId currentPlayer:player withAI:ai multiplayer:multiplayer sync:sync];
    
    //  causes retain cycle with the view controller
    __weak MatchViewController * wself = self;
    [[RACAble(self.match.status) distinctUntilChanged] subscribeNext:^(id x) {
        [wself renderMatchStatus];
    }];
}

- (void)renderMatchStatus {
    self.pentagram.view.hidden = (self.match.status != MatchStatusPlaying);
}

- (void)playMusic {
    SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
    if (sae != nil) {
        [sae preloadBackgroundMusic:@"theme.wav"];
        if (sae.willPlayBackgroundMusic) {
            sae.backgroundMusicVolume = 0.4f;
        }
    }
    
    [sae playBackgroundMusic:@"theme.wav"];
}

- (IBAction)didTapBack:(id)sender {
    [self.match disconnect];
    [WizardDirector unload];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark Pentagram Delegate

-(void)didSelectElement:(NSArray *)elements
{
    //    NSLog(@"selected element %@", elements);
}

-(void)didCastSpell:(NSArray *)elements
{
    NSString * comboId = [Elements comboId:elements];
    NSLog(@"cast spell %@", comboId);
    
    Spell * spell = nil;
    
    if ([comboId isEqualToString:@"FAF"]) {
        spell = [SpellFireball new];
    }
    
    else if ([comboId isEqualToString:@"EWE"]) {
        spell = [SpellEarthwall new];
    }
    
    else if ([comboId isEqualToString:@"AHW"]) {
        spell = [SpellWindblast new];
    }
    
    else if ([comboId isEqualToString:@"EFHW"]) {
        spell = [SpellMonster new];
    }
    
    else if ([comboId isEqualToString:@"WAE"]) {
        spell = [SpellIcewall new];
    }
    
    else if ([comboId isEqualToString:@"WAH"]) {
        spell = [SpellBubble new];
    }
    
    else if ([comboId isEqualToString:@"WAEH"]) {
        spell = [SpellVine new];
    }
    
    else if ([comboId isEqualToString:@"EFAWH"]) {
        spell = nil;
        NSLog(@"CAPTIAN PLANET");
    }
    
    if (spell != nil) {
        [self.match castSpell:spell];
    }
}

- (void)dealloc {
    NSLog(@"MatchViewController: dealloc");
}

@end
