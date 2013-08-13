//
//  SpellSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellSprite.h"
#import "cocos2d.h"
#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellVine.h"
#import "SpellMonster.h"
#import "SpellBubble.h"
#import "SpellIcewall.h"
#import "SpellWindblast.h"
#import "SpellHeal.h"
#import "SpellLevitate.h"
#import "SpellInvisibility.h"
#import "SpellFirewall.h"
#import "SpellFist.h"
#import "SpellHelmet.h"
#import "SpellSleep.h"
#import "SpellLightningOrb.h"

#import "SpellCheeseCaptainPlanet.h"

#import "SpellFailChicken.h"
#import "SpellFailHotdog.h"
#import "SpellFailRainbow.h"
#import "SpellFailTeddy.h"
#import "SpellFailUndies.h"

#import "EffectSleep.h"
#import <ReactiveCocoa.h>

@interface SpellSprite ()
@property (nonatomic, strong) Units * units;
@property (nonatomic, strong) CCSprite * skin;
@property (nonatomic, strong) CCSpriteBatchNode * sheet;
@property (nonatomic, strong) CCAction * frameAnimation;
@property (nonatomic, strong) CCSpriteBatchNode * explosion;
@property (nonatomic) NSInteger currentAltitude;
@property (nonatomic, strong) CCAction * positionAction;
@end

@implementation SpellSprite

+(void)loadSprites {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"LOAD SPELL SPRITES");
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"explode.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"explode-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"fireball.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"fireball-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"earthwall.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"earthwall-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"vine.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"vine-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ogre.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"ogre-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bubble.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"bubble-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"icewall.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"icewall-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"firewall.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"firewall-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"windblast.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"windblast-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"chicken.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"chicken-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lightning.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"lightning-animation.plist"];
        
    });
}


-(id)initWithSpell:(Spell*)spell units:(Units *)units {
    if ((self=[super init])) {
        self.spell = spell;
        self.units = units;
        
        if (spell.targetSelf) {
            return self;
        }
        
        [SpellSprite loadSprites];
        
        // STATIC sprites
        if ([SpellSprite isSingleImage:self.spell]) {
            self.skin = [SpellSprite singleImage:spell];
            [self addChild:self.skin];
            
            if (spell.class == SpellSleep.class || spell.class == SpellFailUndies.class || spell.class == SpellFailTeddy.class || spell.class == SpellFailHotdog.class) {
                CCActionInterval * rotate = [CCRotateBy actionWithDuration:1.4 angle:360.0];
                [self.skin runAction:[CCRepeatForever actionWithAction:rotate]];
            } else if (spell.class == SpellFailRainbow.class) {
                CCActionInterval * fade = [CCFadeIn actionWithDuration:1.0];
                [self.skin runAction:fade];
            }
        }

        // ANIMATED sprites
        else {
            self.sheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png", self.sheetName]];
            [self addChild:self.sheet];
            
            // Make the skin use the right texture, but not decide what to display
            self.skin = [CCSprite spriteWithTexture:self.sheet.texture rect:CGRectZero];
            self.frameAnimation = self.spellAction;
            [self.skin runAction:self.frameAnimation];
            [self.sheet addChild:self.skin];            
        }
        
        
        // TODO add a cool reduce thing to make sure they both get changed or something
        
        [[RACAble(self.spell.position) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderPosition];
        }];
        
        [[RACAble(self.spell.strength) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderWallStrength];
        }];
        
        [[RACAble(self.spell.damage) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderSpellDamage];
        }];
        
        
        [[RACAble(self.spell.status) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderStatus];
        }];
        
        [[RACAble(self.spell.direction) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderDirection];
        }];
        
        [[RACAble(self.spell.effect) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderEffect];
        }];
        
        self.currentAltitude = self.spell.altitude;
        [[RACAble(self.spell.altitude) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderAltitude];
        }];
        
        self.position = ccp(self.spellX, self.spellY);
        [self renderWallStrength];
        [self renderDirection];
        [self renderStatus];
        [self renderAltitude];
    }
    return self;
}

-(void)update:(ccTime)delta {
//    if ([self.spell isKindOfClass:[SpellVine class]]) {
//        return;
//    }
    
    CGFloat y = self.position.y;
    CGFloat x = self.position.x;
    
    CGFloat dxInUnits = self.spell.direction * self.spell.speed * delta;
    CGFloat dxInPixels = [self.units toWidth:dxInUnits];
    x += dxInPixels;
    
    self.position = ccp(x, y);
}

-(BOOL)isWall:(Spell*)spell {
    return ([self.spell isKindOfClass:[SpellWall class]]);
}

-(void)renderDirection {
    self.skin.flipX = (self.spell.direction < 0);
}

-(void)renderPosition {
    // should be 1 tick length?
//    [self stopAction:self.positionAction];
//    self.positionAction = [CCMoveTo actionWithDuration:0.2 position:ccp(self.spellX, self.spellY)];
//    [self runAction:self.positionAction];
    
//    if ([self.spell isKindOfClass:[SpellVine class]]) {
//        if (self.position.x > 0) {
//            // already positioned
//            // just stop it
////            NSLog(@"SKIP VINE");
//            return;
//        }
//    }

    self.position = ccp(self.spellX, self.spellY);
}

- (CGFloat)spellY {
    return [self spellYWithAltitude:self.spell.altitude];
}

-(CGFloat)spellYWithAltitude:(NSInteger)altitude {
    CGFloat y = [self.units altitudeY:altitude];
    
    if ([self isWall:self.spell]) {
        // stuff that needs to be on the ground
        y -= 25;
        
        if ([self.spell isKindOfClass:[SpellFirewall class]]) {
            y -= 12 * (3-self.spell.strength);
        }
    }
    
    if (self.spell.class == SpellFailChicken.class) {
        y -= 50;
    }
    
    else if ([self.spell isType:[SpellHelmet class]]) {
        y += 30;
    }
    
    else if ([self.spell isKindOfClass:[SpellFist class]]) {
        y += 60;
    }
    
    else if ([self.spell isType:[SpellVine class]]) {
        y += 30;
    }    
    
    return y;
}


- (CGFloat)spellX {
    
    CGFloat x = [self.units toX:self.spell.position];
    
    if ([self.spell isType:[SpellHelmet class]]) {
        x -= 15*self.spell.direction;
    }
    
    else if ([self.spell isType:[SpellVine class]]) {
        x -= 15*self.spell.direction;
    }
    
//    else if ([self.spell isKindOfClass:[SpellVine class]]) {
//        // the contentSize is constant. Each frame of Vine has the same size
//        // this is close, but the contentSize is set to the widest frame
//        NSLog(@"SPELL X %f %@", x, NSStringFromCGSize(self.skin.displayFrame.rect.size));
////        if (self.skin.displayFrame.rect.size.width > 0)
////            [self.skin stopAllActions];
////        x = self.units.min - 310 + self.skin.displayFrame.rect.size.width;
//        // it's like they are all right aligned for some reason
////        x = 0;
//        self.skin.anchorPoint = ccp(0,0);
//        x = 0;
//    }
    
    return x;
}

- (void)renderAltitude {
    if ([self.spell isType:[SpellFist class]]) {
        
        if (self.spell.altitude == 2) {
            [self runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(self.spellX, self.spellY)]];
        }
        else if (self.spell.altitude == 1) {
            [self runAction:[CCMoveTo actionWithDuration:1.5 position:ccp(self.spellX, self.spellY - 100)]];
        } else {
        }
    }
}

- (void)renderSpellDamage {
    if (self.spell.damage > 1) {
        self.skin.scale = self.spell.damage;
    }
    else self.skin.scale = 1.0;
}

- (void)renderWallStrength {
    // You don't want to do Firewall here, because it is animated, unlike the others.
    // So you can't do both the strength and the animation
    if (![self isWall:self.spell]) return;
    NSInteger strength = self.spell.strength;
    if (strength < 0) strength = 0;
    if (strength > 3) strength = 3;   
    
    if ([self.spell isKindOfClass:[SpellFirewall class]]) {
        self.skin.scale = (1 + (strength/3.0))/2;
        [self renderPosition];
    } else {
        NSString * frameName = [NSString stringWithFormat:@"%@-%i.png", self.sheetName, (strength+1)];
        [self.skin setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
    }
}

- (void)renderStatus {
//    self.skin.visible = (self.spell.status != SpellStatusDestroyed);
    self.skin.visible = (self.spell.status == SpellStatusActive || self.spell.status == SpellStatusPrepare || self.spell.status == SpellStatusUpdated);

    if (self.spell.status == SpellStatusDestroyed) {
        
        if (self.spell.class == SpellFailRainbow.class) {
            self.skin.visible = YES;
            [self.skin runAction:[CCFadeOut actionWithDuration:1.0]];
        }
        
        else if (!self.explosion) {
            self.explosion = [CCSpriteBatchNode batchNodeWithFile:@"explode.png"];
            [self addChild:self.explosion];
            CCSprite * sprite = [CCSprite spriteWithTexture:self.explosion.texture rect:CGRectZero];
            [sprite runAction:self.explodeAction];
            [sprite runAction:[CCFadeOut actionWithDuration:0.4]];
            [self.explosion addChild:sprite];
        }
    }

}

// crap, I don't know the old value here.
// there's no way to know.
- (void)renderEffect {
    if (self.spell.targetSelf) return;
    
    if ([self.spell.effect class] == [EffectSleep class]) {
        CCFiniteTimeAction * toPos = [CCMoveTo actionWithDuration:0.2 position:ccp(self.spellX, self.spellY - 50)];
        CCFiniteTimeAction * rotate = [CCRotateTo actionWithDuration:0.2 angle:-90.0*self.spell.direction];
        [self stopAction:self.self.frameAnimation];
        [self runAction:toPos];
        [self runAction:rotate];
    }
    
    else {
        [self runAction:[CCMoveTo actionWithDuration:0.2 position:ccp(self.spellX, self.spellY)]];
        [self runAction:[CCRotateTo actionWithDuration:0.2 angle:0]];
    }
}

+(BOOL)isSingleImage:(Spell*)spell {
    return (spell.class == SpellFist.class ||
            spell.class == SpellHelmet.class ||
            spell.class == SpellSleep.class ||
            spell.class == SpellFail.class ||
            spell.class == SpellFailRainbow.class ||
            spell.class == SpellFailHotdog.class ||
            spell.class == SpellFailTeddy.class ||
            spell.class == SpellCheeseCaptainPlanet.class ||
            spell.class == SpellFailUndies.class
            );
}

+(BOOL)isNoRender:(Spell*)spell {
    return (spell.class == SpellInvisibility.class || spell.class == SpellHeal.class || spell.class == SpellLevitate.class);
}

+(CCSprite*)singleImage:(Spell*)spell {
    return [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", [self sheetName:spell]]];
}

+(NSString*)sheetName:(Spell*)spell {
    if ([spell isType:[SpellEarthwall class]]) {
        return @"earthwall";
    }
    
    else if ([spell isType:[SpellVine class]]) {
        return @"vine";
    }
    
    else if ([spell isType:[SpellMonster class]]) {
        return @"ogre";
    }
    
    else if ([spell isType:[SpellBubble class]]) {
        return @"bubble";
    }
    
    else if ([spell isType:[SpellIcewall class]]) {
        return @"icewall";
    }
    
    else if ([spell isType:[SpellWindblast class]]) {
        return @"windblast";
    }
    
    else if ([spell isType:[SpellFirewall class]]) {
        return @"firewall";
    }

    else if ([spell isType:[SpellFist class]]) {
        return @"fist";
    }
    
    else if ([spell isType:[SpellHelmet class]]) {
        return @"helmet";
    }
    
    else if ([spell isType:[SpellSleep class]]) {
        return @"pillow";
    }
    
    else if ([spell isType:[SpellFailChicken class]]) {
        return @"chicken";
    }
    
    else if ([spell isType:[SpellFailHotdog class]]) {
        return @"hotdog";
    }
    
    else if ([spell isType:[SpellFailRainbow class]]) {
        return @"rainbow";
    }
    
    else if ([spell isType:[SpellFailTeddy class]]) {
        return @"teddybear";
    }
    
    else if ([spell isType:[SpellFailUndies class]]) {
        return @"wizard-undies";
    }

    else if ([spell isType:[SpellCheeseCaptainPlanet class]]) {
        return @"captain-planet";
    }
    
    else if ([spell isType:[SpellLightningOrb class]]) {
        return @"lightning";
    }
    
    
    return @"fireball";
}

-(NSString*)sheetName {
    return [SpellSprite sheetName:self.spell];
}

+(NSString*)castAnimationName:(Spell*)spell {
    return [NSString stringWithFormat:@"%@-cast", [self sheetName:spell]];
}

-(NSString*)castAnimationName {
    return [SpellSprite castAnimationName:self.spell];
}


-(CCAction*)spellAction {
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:self.castAnimationName];
    NSAssert(animation, @"Animation not defined");
    animation.restoreOriginalFrame = NO;
    
    if (self.spell.class == SpellFireball.class || self.spell.class == SpellBubble.class || self.spell.class == SpellWindblast.class || self.spell.class == SpellMonster.class || self.spell.class == SpellFailChicken.class || self.spell.class == SpellLightningOrb.class || self.spell.class == SpellFirewall.class) {
        animation.loops = 10000;
    }
    
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
    CCAction * action = actionInterval;
    
    if (self.spell.class == SpellFirewall.class) {
        CCAnimation * startAnimation = [[CCAnimationCache sharedAnimationCache] animationByName:@"firewall-start"];
        startAnimation.loops = 1;
        CCActionInterval * start = [CCAnimate actionWithAnimation:startAnimation];
        CCSequence * startThenBurn = [CCSequence actions:start, actionInterval, nil];
        action = startThenBurn;
    }
    
    
    return action;
}

-(CCAction*)explodeAction {
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"explode"];
    animation.restoreOriginalFrame = NO;
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
    return actionInterval;
}

@end
