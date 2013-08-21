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

#import "SpellEffect.h"

#import "PESleep.h"
#import <ReactiveCocoa.h>

@interface SpellSprite ()
@property (nonatomic, strong) Units * units;
@property (nonatomic, strong) CCAction * frameAnimation;
@property (nonatomic, strong) CCAction * positionAction;
@property (nonatomic, strong) CCAction * explodeAction;
@property (nonatomic) NSInteger currentAltitude;
@end

@implementation SpellSprite

-(id)initWithSpell:(Spell*)spell units:(Units *)units {
    if ((self=[super init])) {
        self.spell = spell;
        self.units = units;
        self.scale = units.spriteScaleModifier;
        
        if (spell.targetSelf) {
//            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fireball-1.png"]];
            self.visible = NO;
            return self;
        }
        
        // STATIC sprites
        if ([SpellSprite isSingleImage:self.spell]) {
            [self setDisplayFrame:[SpellSprite singleImageFrame:spell]];
            
            if (spell.class == SpellSleep.class || spell.class == SpellFailUndies.class || spell.class == SpellFailTeddy.class || spell.class == SpellFailHotdog.class) {
                CCActionInterval * rotate = [CCRotateBy actionWithDuration:1.4 angle:360.0];
                [self runAction:[CCRepeatForever actionWithAction:rotate]];
            } else if (spell.class == SpellFailRainbow.class) {
                CCActionInterval * fade = [CCFadeIn actionWithDuration:1.0];
                [self runAction:fade];
            }
        }

        // ANIMATED sprites
        else {
            // Make the skin use the right texture, but not decide what to display
            CCAnimation * animation = [self spellAnimation];
            self.frameAnimation = [self spellAction:animation];
            [self runAction:self.frameAnimation];
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
        
        [[RACAble(self.spell.spellEffect) distinctUntilChanged] subscribeNext:^(id x) {
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
    
    CGFloat dxInUnits = [self.spell moveDx:delta];
    CGFloat dxInPixels = [self.units toWidth:dxInUnits];
    x += dxInPixels;
    
    if ([self.spell isKindOfClass:[SpellCheeseCaptainPlanet class]]) {
        y += [self flyYForTheCaptain:fabs(dxInUnits)];
    }
    
    CGPoint position = ccp(x, y);
    self.position = position;
}

-(BOOL)isWall:(Spell*)spell {
    return ([self.spell isKindOfClass:[SpellWall class]]);
}

-(void)renderDirection {
    self.flipX = (self.spell.direction < 0);
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

    CGPoint position = ccp(self.spellX, self.spellY);
    if ([self.spell isKindOfClass:[SpellCheeseCaptainPlanet class]]) {
        // send in the change in x from the beginning
        CGFloat dx = self.spell.position;
        if (self.spell.direction < 0) dx = UNITS_MAX - dx;
        position.y += [self flyYForTheCaptain:dx];
    }
    self.position = position;
}

// The flyY depends on
// current x

-(CGFloat)flyYForTheCaptain:(CGFloat)dx {
    // spellY always returns the ground position
    CGFloat dPercentAcross = (dx/UNITS_MAX);
    CGFloat totalFlyDistance = self.units.maxY - self.units.zeroY;
    return dPercentAcross*totalFlyDistance;
}

- (CGFloat)spellY {
    return [self spellYWithAltitude:self.spell.altitude];
}

-(CGFloat)spellYWithAltitude:(NSInteger)altitude {
    CGFloat y = [self.units altitudeY:altitude];
    
    if ([self isWall:self.spell]) {
        // stuff that needs to be on the ground
        y -= 45;
        
        if ([self.spell isKindOfClass:[SpellFirewall class]]) {
            y -= 12 * (3-self.spell.strength) + 8;
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
        self.scale = self.spell.damage * self.units.spriteScaleModifier;
    }
    else self.scale = 1.0*self.units.spriteScaleModifier;
}

- (void)renderWallStrength {
    // You don't want to do Firewall here, because it is animated, unlike the others.
    // So you can't do both the strength and the animation
    if (![self isWall:self.spell]) return;
    NSInteger strength = self.spell.strength;
    if (strength < 0) strength = 0;
    if (strength > 3) strength = 3;
    
//    NSLog(@"RENDER WALL %i", strength);
    
    if ([self.spell isKindOfClass:[SpellFirewall class]]) {
        self.scale = self.units.spriteScaleModifier * (1 + (strength/3.0))/2;
        [self renderPosition];
    } else {
        if (self.frameAnimation.isDone) {
            NSString * frameName = [NSString stringWithFormat:@"%@-%i.png", self.sheetName, (strength+1)];
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
        }
    }
}

- (void)renderStatus {
//    self.skin.visible = (self.spell.status != SpellStatusDestroyed);
//    self.visible = (self.spell.status == SpellStatusActive || self.spell.status == SpellStatusPrepare || self.spell.status == SpellStatusUpdated);

    if (self.spell.status == SpellStatusDestroyed) {
        
        if (self.spell.class == SpellFailRainbow.class) {
            self.visible = YES;
            [self runAction:[CCFadeOut actionWithDuration:1.0]];
        }
        
        else if (!self.explodeAction) {
            CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"explode"];
            self.explodeAction = [CCAnimate actionWithAnimation:animation];
            [self stopAction:self.frameAnimation];
            self.frameAnimation = self.explodeAction;
            [self runAction:self.explodeAction];
            [self runAction:[CCFadeOut actionWithDuration:0.4]];
        }
    }

}

// crap, I don't know the old value here.
// there's no way to know.
- (void)renderEffect {
    if (self.spell.targetSelf) return;
    
    if ([self.spell.spellEffect class] == [SESleep class]) {
        CCFiniteTimeAction * toPos = [CCMoveTo actionWithDuration:0.2 position:ccp(self.spellX, self.spellY - 50)];
        CCFiniteTimeAction * rotate = [CCRotateTo actionWithDuration:0.2 angle:-90.0*self.spell.direction];
        [self stopAction:self.self.frameAnimation];
        self.frameAnimation = nil;        
        [self runAction:toPos];
        [self runAction:rotate];
    }
    
    else {
        [self runAction:[CCMoveTo actionWithDuration:0.2 position:ccp(self.spellX, self.spellY)]];
        [self runAction:[CCRotateTo actionWithDuration:0.2 angle:0]];
        
        if (!self.frameAnimation) {
            CCAnimation * animation = [self spellAnimation];
            self.frameAnimation = [self spellAction:animation];
            [self runAction:self.frameAnimation];            
        }
    }
}

+(BOOL)isSingleImage:(Spell*)spell {
    return (spell.class == SpellFist.class ||
            spell.class == SpellHelmet.class ||
            spell.class == SpellSleep.class ||
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

+(CCSpriteFrame*)singleImageFrame:(Spell*)spell {
    NSString * frameName = [NSString stringWithFormat:@"%@.png", [self sheetName:spell]];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

+(NSString*)sheetNameForClass:(Class)spellClass {
    if (spellClass == [SpellEarthwall class]) {
        return @"earthwall";
    }
    
    else if (spellClass == [SpellVine class]) {
        return @"vine";
    }
    
    else if (spellClass == [SpellMonster class]) {
        return @"ogre";
    }
    
    else if (spellClass == [SpellBubble class]) {
        return @"bubble";
    }
    
    else if (spellClass == [SpellIcewall class]) {
        return @"icewall";
    }
    
    else if (spellClass == [SpellWindblast class]) {
        return @"windblast";
    }
    
    else if (spellClass == [SpellFirewall class]) {
        return @"firewall";
    }
    
    else if (spellClass == [SpellFist class]) {
        return @"fist";
    }
    
    else if (spellClass == [SpellHelmet class]) {
        return @"helmet";
    }
    
    else if (spellClass == [SpellSleep class]) {
        return @"pillow";
    }
    
    else if (spellClass == [SpellFailChicken class]) {
        return @"chicken";
    }
    
    else if (spellClass == [SpellFailHotdog class]) {
        return @"hotdog";
    }
    
    else if (spellClass == [SpellFailRainbow class]) {
        return @"rainbow";
    }
    
    else if (spellClass == [SpellFailTeddy class]) {
        return @"teddybear";
    }
    
    else if (spellClass == [SpellFailUndies class]) {
        return @"wizard-undies";
    }
    
    else if (spellClass == [SpellCheeseCaptainPlanet class]) {
        return @"captain-planet";
    }
    
    else if (spellClass == [SpellLightningOrb class]) {
        return @"lightning";
    }
    
    else if (spellClass == [SpellFireball class]) {
        return @"fireball";
    }
    
    return nil;
}

+(NSString*)sheetName:(Spell*)spell {
    return [self sheetNameForClass:spell.class];
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

-(CCAnimation*)spellAnimation {
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:self.castAnimationName];
    NSAssert(animation, @"Animation not defined");
    animation.restoreOriginalFrame = NO;
    
    if (self.spell.class == SpellFireball.class || self.spell.class == SpellBubble.class || self.spell.class == SpellWindblast.class || self.spell.class == SpellMonster.class || self.spell.class == SpellFailChicken.class || self.spell.class == SpellLightningOrb.class) {
        animation.loops = 10000;
    }
    
    return animation;
}

-(CCAction*)spellAction:(CCAnimation*)animation {
    
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
    CCAction * action = actionInterval;
    
    if (self.spell.class == SpellFirewall.class) {
        CCAnimation * burnAnimation = [[CCAnimationCache sharedAnimationCache] animationByName:@"firewall-burn"];
        burnAnimation.loops = 10000;
        CCActionInterval * burn = [CCAnimate actionWithAnimation:burnAnimation];
        CCSequence * startThenBurn = [CCSequence actions:actionInterval, burn, nil];
        action = startThenBurn;
    }
    
    return action;
}

@end
