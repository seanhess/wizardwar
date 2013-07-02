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
#import "AppStyle.h"
#import "Color.h"

@interface MatchViewController () <PentagramDelegate>
@property (strong, nonatomic) PentagramViewController * pentagram;
@property (weak, nonatomic) IBOutlet UIView *pentagramView;
@property (weak, nonatomic) IBOutlet UIView *cocosView;
@property (strong, nonatomic) Match * match;
@property (strong, nonatomic) Combos * combos;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *subMessage;
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
    
    self.message.font = [UIFont fontWithName:FONT_COMIC_ZINE size:100];
    self.message.textColor = UIColorFromRGB(0xF9A843);
    
    self.subMessage.font = [UIFont fontWithName:FONT_COMIC_ZINE size:40];
    self.subMessage.textColor = UIColorFromRGB(0xCACACA);
    self.subMessage.hidden = YES;
    
    self.pentagram = [PentagramViewController new];
    self.pentagram.delegate = self;
    [self.pentagramView addSubview:self.pentagram.view];
    [self.pentagram viewDidLoad];
    
    [self playMusic];
    
    CCDirectorIOS * director = [WizardDirector shared];
    [self.cocosView addSubview:director.view];
    
    
    self.combos = [Combos new];
    
    
    //  causes retain cycle with the view controller
    __weak MatchViewController * wself = self;
    [[RACAble(self.match.status) distinctUntilChanged] subscribeNext:^(id x) {
        [wself renderMatchStatus];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    // Add the director's view to us
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    CCDirectorIOS * director = [WizardDirector shared];
    NSLog(@"TESTING cososView=%@ self.view=%@", NSStringFromCGRect(self.cocosView.bounds), NSStringFromCGRect(self.view.bounds));
    director.view.frame = self.view.bounds;
    MatchLayer * matchLayer = [[MatchLayer alloc] initWithMatch:self.match size:self.view.bounds.size];
    [WizardDirector runLayer:matchLayer];
    
    // CONNECT / START!
    // this always happens after? LAME!
    [self.match connect];
    
    [self renderMatchStatus];    
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)createMatch:(Challenge*)challenge currentWizard:(Wizard*)wizard withAI:(Wizard*)ai multiplayer:(id<Multiplayer>)multiplayer sync:(TimerSyncService*)sync {
}

- (id<Multiplayer>)defaultMultiplayerService {
    MultiplayerService * mp = [MultiplayerService new];
#if DEBUG
    mp.simulatedLatency = 0.5;
    NSLog(@"*** SIMULATED LATENCY *** %f", mp.simulatedLatency);
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

- (void)renderMatchStatus {
    self.pentagram.view.hidden = (self.match.status != MatchStatusPlaying);
    self.subMessage.hidden = YES;
    
    if (self.match.status == MatchStatusReady) {
        self.message.alpha = 1.0;
        self.message.textColor = UIColorFromRGB(0xF9A843);
        self.message.text = @"READY?";
    }
    
    else if (self.match.status == MatchStatusPlaying) {
        self.message.textColor = UIColorFromRGB(0xF9A843);
        self.message.text = @"WAR!";
        
        [UIView animateWithDuration:1.0 animations:^{
            self.message.alpha = 0;
        }];
    }
    
    else if (self.match.status == MatchStatusEnded) {
        self.message.alpha = 1.0;
        if (self.match.currentWizard.state == WizardStatusWon) {
            self.message.textColor = UIColorFromRGB(0x18AB34);
            self.message.text = @"YOU WON!";
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"YouWon.mp3" loop:NO];
        }
        else {
            self.message.textColor = UIColorFromRGB(0xB02410);
            self.message.text = @"DEATH!";
            self.subMessage.hidden = NO;
            self.subMessage.textColor = UIColorFromRGB(0xCACACA);
            self.subMessage.text = @"(YOU LOSE)";
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"YouLose2.mp3" loop:NO];      
        }
    }
}

- (void)playMusic {
    SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
    if (sae != nil) {
        [sae preloadBackgroundMusic:@"theme.wav"];
        [sae preloadBackgroundMusic:@"YouWon.mp3"];
        [sae preloadBackgroundMusic:@"YouLose2.mp3"];
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
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
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
