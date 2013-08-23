//
//  SpellSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellSprite.h"
#import "cocos2d.h"
#import "SpellVine.h"
#import "SpellMonster.h"
#import "SpellEffectService.h"

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
            
            if ([spell isAnyType:@[Sleep, Undies, Teddy, Hotdog]]) {
                CCActionInterval * rotate = [CCRotateBy actionWithDuration:1.4 angle:360.0];
                [self runAction:[CCRepeatForever actionWithAction:rotate]];
            } else if ([spell isType:Rainbow]) {
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
    
    CGFloat dyUnits = self.spell.speedY*delta;
    CGFloat dyPixels = [self.units toHeight:dyUnits];
    
    if ([self.spell isType:CaptainPlanet]) {
        y += [self flyYForTheCaptain:fabs(dxInUnits)];
    } else {
        y += dyPixels;
    }
    
    CGPoint position = ccp(x, y);
    self.position = position;
}

-(void)renderDirection {
    self.flipX = (self.spell.direction < 0);
}

-(void)renderPosition {
    CGPoint position = ccp(self.spellX, self.spellY);
    if ([self.spell isType:CaptainPlanet]) {
        // send in the change in x from the beginning
        CGFloat dx = self.spell.position;
        if (self.spell.direction < 0) dx = UNITS_MAX - dx;
        position.y += [self flyYForTheCaptain:dx];
    } else if ([self.spell isType:Vine]) {
        if (self.spell.position == UNITS_MIN || self.spell.position == UNITS_MAX)
            return;
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

-(CGFloat)spellYWithAltitude:(CGFloat)altitude {
    CGFloat y = [self.units altitudeY:altitude];
    
    if (self.spell.isWall) {
        // stuff that needs to be on the ground
        y -= 45;
        
        if ([self.spell isType:Firewall]) {
            y -= 12 * (3-self.spell.strength) + 8;
        }
    }
    
    if ([self.spell isType:Chicken]) {
        y -= 50;
    }
    
    else if ([self.spell isType:Helmet]) {
        y += 30;
    }
    
    else if ([self.spell isType:Fist]) {
        y += 60;
    }
    
    else if ([self.spell isType:Vine]) {
        y += 30;
    }
    
    return y;
}


- (CGFloat)spellX {
    
    CGFloat x = [self.units toX:self.spell.position];
    
    if ([self.spell isType:Helmet]) {
        x -= 15*self.spell.direction;
    }
    
    else if ([self.spell isType:Vine]) {
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
    CGPoint position = ccp(self.spellX, self.spellY);
    self.position = position;
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
    if (!self.spell.isWall) return;
    NSInteger strength = self.spell.strength;
    if (strength < 0) strength = 0;
    if (strength > 3) strength = 3;
    
//    NSLog(@"RENDER WALL %i", strength);
    
    if ([self.spell isType:Firewall]) {
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
        
        if ([self.spell isType:Rainbow]) {
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
    return ([spell isAnyType:@[Fist, Helmet, Sleep, Rainbow, Hotdog, Teddy, CaptainPlanet, Undies]]);
}

+(CCSpriteFrame*)singleImageFrame:(Spell*)spell {
    NSString * frameName = [NSString stringWithFormat:@"%@.png", [self sheetName:spell]];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

// See SpellEffectService.h, name the sprites to match the type constants there :)
+(NSString*)sheetNameForType:(NSString *)type {
    return type;
}

+(NSString*)sheetName:(Spell*)spell {
    return [self sheetNameForType:spell.type];
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
    
    if ([self.spell isAnyType:@[Fireball, Bubble, Windblast, Monster, Chicken, Lightning]]) {
        animation.loops = 10000;
    }
    
    return animation;
}

-(CCAction*)spellAction:(CCAnimation*)animation {
    
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
    CCAction * action = actionInterval;
    
    if ([self.spell isType:Firewall]) {
        CCAnimation * burnAnimation = [[CCAnimationCache sharedAnimationCache] animationByName:@"firewall-burn"];
        burnAnimation.loops = 10000;
        CCActionInterval * burn = [CCAnimate actionWithAnimation:burnAnimation];
        CCSequence * startThenBurn = [CCSequence actions:actionInterval, burn, nil];
        action = startThenBurn;
    }
    
    return action;
}

@end
