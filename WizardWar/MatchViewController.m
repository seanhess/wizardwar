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
#import "MatchLayer.h"
#import "SimpleAudioEngine.h"
#import "Elements.h"

#import "Match.h"
#import "MultiplayerService.h"
#import <ReactiveCocoa.h>
#import "TimerSyncService.h"
#import "Combos.h"
#import "AppStyle.h"
#import "ConnectionService.h"
#import "UIColor+Hex.h"
#import "AnalyticsService.h"
#import "OLUnitsService.h"

@interface MatchViewController ()
@property (strong, nonatomic) PentagramViewController * pentagram;
@property (weak, nonatomic) IBOutlet UIView *pentagramView;
@property (weak, nonatomic) IBOutlet UIView *cocosView;
@property (strong, nonatomic) Match * match;
@property (strong, nonatomic) Combos * combos;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *subMessage;
@end

@implementation MatchViewController

- (id)init {
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;        
    }
    return self;
}

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
    [AnalyticsService event:@"MatchLoad"];    
    
    NSLog(@"MatchVC.viewDidLoad");
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];    
    
    self.message.font = [UIFont fontWithName:FONT_COMIC_ZINE size:88];
    self.message.textColor = [UIColor colorFromRGB:0xF9A843];
    
    self.subMessage.font = [UIFont fontWithName:FONT_COMIC_ZINE size:40];
    self.subMessage.textColor = [UIColor colorFromRGB:0xCACACA];
    
    self.combos = [Combos new];
    
    self.pentagram = [PentagramViewController new];
    self.pentagram.combos = self.combos;
    [self.pentagramView addSubview:self.pentagram.view];
    [self.pentagram viewDidLoad];
    
    [self playMusic];
    
    CCDirector * director = [CCDirector sharedDirector];
    [self.cocosView addSubview:director.view];
    
    
    
    __weak MatchViewController * wself = self;
    
    // Monitor Connection so we can disconnect and reconnect
    [RACAble(ConnectionService.shared, isUserActive) subscribeNext:^(id x) {
        [wself onChangedIsUserActive:ConnectionService.shared.isUserActive];
    }];
    
    [[RACAble(self.match.status) distinctUntilChanged] subscribeNext:^(id x) {
        [wself renderMatchStatus];
    }];
    
    [[RACAble(self.combos.castSpell) distinctUntilChanged] subscribeNext:^(Spell * spell) {
        [wself didCastSpell:spell];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    // Add the director's view to us
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    CCDirector * director = [CCDirector sharedDirector];
    NSLog(@"MatchVC.viewWillAppear");
    director.view.frame = self.view.bounds;
    MatchLayer * matchLayer = [[MatchLayer alloc] initWithMatch:self.match size:self.view.bounds.size combos:self.combos units:[OLUnitsService.shared units]];
    [WizardDirector runLayer:matchLayer];
    
    // CONNECT / START!
    // this always happens after? LAME!
    [self.match connect];
    
    [self renderMatchStatus];    
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)onChangedIsUserActive:(BOOL)active {
    if (!active) {
        [self leaveMatch];
    }
}

- (void)createMatch:(Challenge*)challenge currentWizard:(Wizard*)wizard withAI:(Wizard*)ai multiplayer:(id<Multiplayer>)multiplayer sync:(TimerSyncService*)sync {
}

- (id<Multiplayer>)defaultMultiplayerService {
    MultiplayerService * mp = [MultiplayerService new];
#if DEBUG
//    mp.simulatedLatency = 0.5;
//    NSLog(@"*** SIMULATED LATENCY *** %f", mp.simulatedLatency);
#endif
    return mp;
}

- (TimerSyncService*)defaultSyncService {
    return [TimerSyncService new];
}

- (void)startChallenge:(Challenge *)challenge currentWizard:(Wizard *)wizard {
    // join in the ready screen!
    self.match = [[Match alloc] initWithMatchId:challenge.matchId hostName:challenge.main.name currentWizard:wizard withAI:nil multiplayer:self.defaultMultiplayerService sync:self.defaultSyncService];
}

- (void)startMatchAsWizard:(Wizard *)wizard withAI:(Wizard *)ai {
    self.match = [[Match alloc] initWithMatchId:@"Practice" hostName:wizard.name currentWizard:wizard withAI:ai multiplayer:nil sync:nil];
}

// I want to unsubscribe from this when the match ends.
- (void)renderMatchStatus {
    
    if (!self.match) return;

    NSLog(@"MatchVC.renderMatchStatus %i", self.match.status);
    self.pentagram.view.hidden = (self.match.status != MatchStatusPlaying);
    self.subMessage.textColor = [UIColor colorFromRGB:0xCACACA];
    self.subMessage.alpha = 1.0;
    
    if (self.match.status == MatchStatusReady) {
        self.message.alpha = 1.0;
        self.message.textColor = [UIColor colorFromRGB:0xF9A843];
        self.message.text = @"WAITING";
        self.subMessage.alpha = 0.0;
//        self.subMessage.text = @"can't war yo-self";
    }
    
    else if (self.match.status == MatchStatusSyncing) {
        self.message.alpha = 1.0;
        self.message.textColor = [UIColor colorFromRGB:0xF9A843];
        self.message.text = @"READY?";
        self.subMessage.alpha = 0.0;
//        self.subMessage.text = @"tuning essences";        
    }
    
    else if (self.match.status == MatchStatusPlaying) {
        self.message.textColor = [UIColor colorFromRGB:0xF9A843];
        self.message.text = @"WAR!";
        self.subMessage.text = @"";                
        
        [UIView animateWithDuration:1.0 animations:^{
            self.subMessage.alpha = 0;            
            self.message.alpha = 0;
        }];
    }
    
    else if (self.match.status == MatchStatusEnded) {
        self.message.alpha = 1.0;
        if (self.match.currentWizard.state == WizardStatusDead) {
            self.message.textColor = [UIColor colorFromRGB:0xB02410];
            self.message.text = @"DEATH!";
            self.subMessage.alpha = 1.0;
            self.subMessage.text = @"(YOU LOSE)";
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"YouLose2.mp3" loop:NO];
        }
        
        else {
            self.message.textColor = [UIColor colorFromRGB:0x18AB34];
            self.message.text = @"YOU WON!";
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"YouWon.mp3" loop:NO];
        }
    }
}

- (void)playMusic {
    SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
    if (sae != nil) {
        [sae preloadBackgroundMusic:@"theme.mp3"];
        [sae preloadBackgroundMusic:@"YouWon.mp3"];
        [sae preloadBackgroundMusic:@"YouLose2.mp3"];
        if (sae.willPlayBackgroundMusic) {
            sae.backgroundMusicVolume = 0.4f;
        }
    }
    
    [sae playBackgroundMusic:@"theme.mp3"];
}

- (IBAction)didTapBack:(id)sender {
    [self leaveMatch];
}

- (void)leaveMatch {
    NSLog(@"MatchVC.leaveMatch");
    [self.match disconnect];
    [WizardDirector unload];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.match = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    //    [self.navigationController popViewControllerAnimated:YES];    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Pentagram Delegate

-(void)didCastSpell:(Spell *)spell;
{
    if (spell) {
        // now, disable the basturd
        [self.match castSpell:spell];
        [self.pentagram delayCast:spell.castDelay];
    }
}

- (void)dealloc {
    NSLog(@"MatchViewController: dealloc");
}

@end
