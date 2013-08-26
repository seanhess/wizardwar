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
#import "UIViewController+Idiom.h"
#import <BButton.h>
#import "MenuButton.h"
#import <NSString+FontAwesome.h>
#import "AppStyle.h"
#import "HelpViewController.h"
#import "ChallengeService.h"
#import "SpellbookService.h"
#import "ConnectionService.h"
#import "RACSignal+Filters.h"
#import "QuestLevel.h"
#import "QuestService.h"

@interface MatchViewController () <HelpDelegate, PentagramDelegate>
@property (strong, nonatomic) PentagramViewController * pentagram;
@property (weak, nonatomic) IBOutlet UIView *pentagramView;
@property (weak, nonatomic) IBOutlet UIView *cocosView;
@property (strong, nonatomic) Match * match;
@property (strong, nonatomic) Combos * combos;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *subMessage;
@property (strong, nonatomic) MenuButton *replayButton;
@property (nonatomic, strong) Challenge * challenge;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (strong, nonatomic) QuestLevel * questLevel;

@property (strong, nonatomic) HelpViewController *help;
@property (nonatomic) MatchStatus matchStatus;
@property (strong, nonatomic) Spell * castSpell;
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
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [AnalyticsService event:@"MatchLoad"];    
    
    NSLog(@"MatchVC.viewDidLoad");
    
    self.helpButton.titleLabel.font = [UIFont fontWithName:FONT_AWESOME size:38];
    [self.helpButton setTitle:[NSString stringFromAwesomeIcon:FAIconQuestionSign] forState:UIControlStateNormal];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];    
    
    self.message.font = [UIFont fontWithName:FONT_COMIC_ZINE size:88];
    self.message.textColor = [UIColor colorFromRGB:0xF9A843];
    
    self.subMessage.font = [UIFont fontWithName:FONT_COMIC_ZINE size:40];
    self.subMessage.textColor = [UIColor colorFromRGB:0xCACACA];
    self.subMessage.alpha = 0.0;
    
    self.combos = [Combos new];
    
    NSLog(@" - pv size %@", NSStringFromCGRect(self.pentagramView.frame));
    self.pentagram = [[PentagramViewController alloc] initPerIdoim];
    self.pentagram.delegate = self;
    self.pentagram.combos = self.combos;
//    self.pentagram.view.frame = CGRectMake(0, 0, 100, 100);
    self.pentagram.view.frame = self.pentagramView.bounds;
    [self.pentagramView addSubview:self.pentagram.view];
    
    // You don't need to call viewDidLoad on pentagram I guess
    // Maybe it gets called automatically after the frame is set?
    
    CCDirector * director = [CCDirector sharedDirector];
    [self.cocosView addSubview:director.view];
    
    // REPLAY BUTTONS
    self.replayButton = [[MenuButton alloc] initWithFrame:CGRectMake(self.cocosView.center.x-125, self.cocosView.frame.size.height, 250, 80)];
    [self.replayButton setTitle:@"Leave" forState:UIControlStateNormal];
    [self.replayButton addTarget:self action:@selector(didTapLeave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.replayButton];
    [self.replayButton calculatePadding];
}

- (void)startMatch {
    [self startMatch:self.match];
}

- (void)startMatch:(Match*)match {
    NSLog(@"START MATCH %@", match);
    
    self.match = match;
    
    [self playMusic];

    MatchLayer * matchLayer = [[MatchLayer alloc] initWithMatch:self.match size:self.view.bounds.size combos:self.combos units:[OLUnitsService.shared units]];
    self.pentagram.drawingLayer = matchLayer.drawingLayer;
    [WizardDirector runLayer:matchLayer];
    
    // Match starts.... NOW
    [self.match connect];
    
    __weak MatchViewController * wself = self;
    
    // Monitor Connection so we can disconnect and reconnect
    [RACAble(ConnectionService.shared, isUserActive) subscribeNext:^(id x) {
        [wself onChangedIsUserActive:ConnectionService.shared.isUserActive];
    }];
    
    RAC(self.castSpell) = [RACAble(self.combos.castSpell) distinctUntilChanged];
    
    RAC(self.matchStatus) = matchLayer.matchStatusSignal;
    
    RACSignal * hideControls = [matchLayer.showControlsSignal not];
    RAC(self.pentagram.hidden) = hideControls;
    RAC(self.pentagram.disabled) = [RACAble(self.match.ai.disableControls) safe];
    RAC(self.message.hidden) = matchLayer.aiHideControlsSignal;
    RAC(self.subMessage.hidden) = matchLayer.aiHideControlsSignal;
    RAC(self.combos.allowedSpells) = RACAble(self.match.ai.allowedSpells);
    RAC(self.pentagram.helpSelectElements) = RACAble(self.match.ai.helpSelectedElements);
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // The size is finally correct here. Set it so it matches
    CCDirector * director = [CCDirector sharedDirector];
    director.view.frame = self.view.bounds;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)onChangedIsUserActive:(BOOL)active {
    if (!active) {
        [self leaveMatch];
    }
}

- (id<Multiplayer>)defaultMultiplayerService {
    MultiplayerService * mp = [[MultiplayerService alloc] initWithRootRef:[ConnectionService.shared root]];
#if DEBUG
//    mp.simulatedLatency = 0.5;
//    NSLog(@"!!! SIMULATED LATENCY *** %f", mp.simulatedLatency);
#endif
    return mp;
}

- (void)createMatchWithChallenge:(Challenge *)challenge currentWizard:(Wizard *)wizard {
    // join in the ready screen!
    self.challenge = challenge;
    TimerSyncService.shared.root = [ConnectionService.shared root];
    Match * match = [[Match alloc] initWithMatchId:challenge.matchId hostName:challenge.main.name currentWizard:wizard withAI:nil multiplayer:self.defaultMultiplayerService sync:[TimerSyncService shared]];
    self.match = match;
}

- (void)createMatchWithWizard:(Wizard *)wizard withLevel:(QuestLevel *)level {
    self.questLevel = level;
    
    Match * match = [[Match alloc] initWithMatchId:@"Quest" hostName:wizard.name currentWizard:wizard withAI:[level.ai create] multiplayer:nil sync:nil];
    self.match = match;
}

// then do it whenever any of them change... 
// pentagram visible = match.status == MatchStatusPlaying && (!ai.disablePentagram)

// I want to unsubscribe from this when the match ends.
- (void)setMatchStatus:(MatchStatus)matchStatus {
    _matchStatus = matchStatus;
    if (!self.match) return;

    NSLog(@"MatchVC.renderMatchStatus %i", self.match.status);
    self.subMessage.textColor = [UIColor colorFromRGB:0xCACACA];
    self.subMessage.alpha = 1.0;
    
    if (self.match.status != MatchStatusEnded)
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];
    else
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
    
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
        
        // [self.pentagram showHelpMessage];
    }
    
    else if (self.match.status == MatchStatusEnded) {
        self.message.alpha = 1.0;
        BOOL didWin = (self.match.currentWizard.state != WizardStatusDead);
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
            self.subMessage.alpha = 0.0;
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"YouWon.mp3" loop:NO];
        }
        
        [self didFinishMatch:YES didWin:didWin];
        [self showEndButtons];
    }
}

- (void)playMusic {
    SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
    if (sae != nil) {
        [sae preloadBackgroundMusic:@"theme.mp3"];
        [sae preloadBackgroundMusic:@"YouWon.mp3"];
        [sae preloadBackgroundMusic:@"YouLose2.mp3"];
        if (sae.willPlayBackgroundMusic) {
            sae.backgroundMusicVolume = 0.2f;
        }
    }
    [sae playBackgroundMusic:@"theme.mp3"];
 
#if TARGET_IPHONE_SIMULATOR
    sae.backgroundMusicVolume = 0.0;
#endif
    
}

- (void)didFinishMatch:(BOOL)didFinish didWin:(BOOL)didWin {
    // always mark the challenge as lost
    if (self.challenge) {
        [self.delegate didFinishChallenge:self.challenge didWin:didWin];
    }
    
    // it doesn't matter for these guys?
    if (didFinish) {
        // Don't mark them as finished unless you actually finish
        [SpellbookService.shared finishedMatch:self.match.mainPlayerSpellHistory didWin:didWin];
        [QuestService.shared finishedQuest:self.questLevel didWin:didWin];
    }
    
//    NSArray * achievements = [challengeAchievements ]
}

- (IBAction)didTapBack:(id)sender {
    [self leaveMatch];
}

- (void)didTapLeave:(id)sender {
    [self leaveMatch];
}

- (void)leaveMatch {
    NSLog(@"MatchVC.leaveMatch");
    
    if (self.match.status != MatchStatusEnded) {
        // you leave early = you lose
        [self didFinishMatch:NO didWin:NO];
    }
    
    [SimpleAudioEngine end];
    
    [self.match disconnect];
    [WizardDirector unload];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.match = nil;
    [ChallengeService.shared removeChallenge:self.challenge];
    [self dismissViewControllerAnimated:YES completion:nil];
    //    [self.navigationController popViewControllerAnimated:YES];    
}

- (void)showEndButtons {
    if (self.match.currentWizard.state == WizardStatusDead) {
        [self.replayButton setTitle:@"Run Away" forState:UIControlStateNormal];
    } else {
        [self.replayButton setTitle:@"Return Victorious!" forState:UIControlStateNormal];
    }

    // My view's size is wacked at this point. Use cocos2d view I guess.
    CGRect frame = self.replayButton.frame;
    frame.origin.x = self.cocosView.center.x - frame.size.width/2;
    self.replayButton.frame = frame;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.replayButton.frame;
        frame.origin.y = self.cocosView.frame.size.height - frame.size.height - 8;
        self.replayButton.frame = frame;
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showHelp:(HelpViewController*)help {
    help.view.frame = self.view.bounds;
    help.view.alpha = 0.0;
    [self.view addSubview:help.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        help.view.alpha = 1.0;
    }];
    
    // need strong reference or the view controller stops working
    self.help = help;
}

- (void)hideHelp:(HelpViewController*)help {
    [UIView animateWithDuration:0.5 animations:^{
        help.view.frame = self.helpButton.frame;
        help.imageView.frame = help.view.bounds;
        help.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [help.view removeFromSuperview];
    }];    
}

- (IBAction)didTapHelp:(id)sender {
    HelpViewController * help = [HelpViewController new];
    help.delegate = self;
    [self showHelp:help];
}

- (void)didTapHelpClose:(HelpViewController *)help {
    [self hideHelp:help];
}



# pragma mark Pentagram Delegate

-(void)didTapPentagram {
    // don't send taps before we've started. During the cooldown period
    if (self.match.status == MatchStatusPlaying || self.match.status == MatchStatusEnded)
        [self.match.ai didTapControls];
}

-(void)setCastSpell:(Spell *)spell;
{
    if (spell) {
        BOOL success = [self.match castSpell:spell];
        if (success) {
            [self.pentagram delayCast:spell.castDelay];
        }
        else {
            [self.pentagram attemptedCastButFailedBecauseOfSleep];
        }
    }
}

- (void)dealloc {
    NSLog(@"MatchViewController: dealloc");
}

@end
