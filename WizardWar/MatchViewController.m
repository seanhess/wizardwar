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

#import "Match.h"
#import "MultiplayerService.h"
#import <ReactiveCocoa.h>
#import "TimerSyncService.h"
#import "Combos.h"

@interface MatchViewController () <PentagramDelegate>
@property (strong, nonatomic) PentagramViewController * pentagram;
@property (weak, nonatomic) IBOutlet UIView *pentagramView;
@property (weak, nonatomic) IBOutlet UIView *cocosView;
@property (strong, nonatomic) Match * match;
@property (strong, nonatomic) Combos * combos;
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
    
    self.pentagram = [PentagramViewController new];
    self.pentagram.delegate = self;
    [self.pentagramView addSubview:self.pentagram.view];
    [self.pentagram viewDidLoad];
    
    
    [self playMusic];
    
    CCDirectorIOS * director = [WizardDirector shared];
    [self.cocosView addSubview:director.view];
    
    
    self.combos = [Combos new];
}

- (void)viewWillAppear:(BOOL)animated {
    // Add the director's view to us

    CCDirectorIOS * director = [WizardDirector shared];
    director.view.frame = self.cocosView.bounds;
    MatchLayer * matchLayer = [[MatchLayer alloc] initWithMatch:self.match size:self.view.bounds.size];
    [WizardDirector runLayer:matchLayer];
    
    [self renderMatchStatus];    
}

- (void)connectToMatchWithId:(NSString*)matchId currentPlayer:(Player*)player withAI:(Player*)ai {
    id<Multiplayer> multiplayer = nil;
    TimerSyncService * sync = nil;
    if (ai) { }
    else {
        MultiplayerService * mp = [MultiplayerService new];
#if DEBUG
        mp.simulatedLatency = 0.5;
        NSLog(@"*** SIMULATED LATENCY *** %f", mp.simulatedLatency);
#endif
        multiplayer = mp;
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
    Spell * spell = [self.combos spellForElements:elements];
    if (spell) {
        [self.match castSpell:spell];
    }
}

- (void)dealloc {
    NSLog(@"MatchViewController: dealloc");
}

@end
