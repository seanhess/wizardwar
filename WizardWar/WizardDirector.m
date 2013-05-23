//
//  WWDirector.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "WizardDirector.h"
#import "cocos2d.h"

@interface WizardDirector ()

@end

@implementation WizardDirector

+ (CCDirectorIOS *)shared
{
    // make sure to call initialize right away!
    CCDirectorIOS * director = (CCDirectorIOS*) [CCDirector sharedDirector];
    return director;
}

+(CCDirectorIOS*)initializeWithBounds:(CGRect)bounds {
    // Custom initialization
    
    // CCGLView creation
    // viewWithFrame: size of the OpenGL view. For full screen use [_window bounds]
    //  - Possible values: any CGRect
    // pixelFormat: Format of the render buffer. Use RGBA8 for better color precision (eg: gradients). But it takes more memory and it is slower
    //	- Possible values: kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
    // depthFormat: Use stencil if you plan to use CCClippingNode. Use Depth if you plan to use 3D effects, like CCCamera or CCNode#vertexZ
    //  - Possible values: 0, GL_DEPTH_COMPONENT24_OES, GL_DEPTH24_STENCIL8_OES
    // sharegroup: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads
    //  - Possible values: nil, or any valid EAGLSharegroup group
    // multiSampling: Whether or not to enable multisampling
    //  - Possible values: YES, NO
    // numberOfSamples: Only valid if multisampling is enabled
    //  - Possible values: 0 to glGetIntegerv(GL_MAX_SAMPLES_APPLE)
    CCGLView *glView = [CCGLView viewWithFrame:bounds
                                   pixelFormat:kEAGLColorFormatRGB565
                                   depthFormat:0
                            preserveBackbuffer:NO
                                    sharegroup:nil
                                 multiSampling:NO
                               numberOfSamples:0];

    // Multiple Touches enabled
    [glView setMultipleTouchEnabled:YES];

    CCDirectorIOS * director = (CCDirectorIOS*) [CCDirector sharedDirector];
    
    director.wantsFullScreenLayout = YES;

    // Display FSP and SPF
    [director setDisplayStats:YES];
    
    // set FPS at 60
    [director setAnimationInterval:1.0/60];
    
    // attach the openglView to the director
    [director setView:glView];
    
    // 2D projection
    [director setProjection:kCCDirectorProjection2D];
    //	[director setProjection:kCCDirectorProjection3D];
    
    // Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    if( ! [director enableRetinaDisplay:YES] )
        CCLOG(@"Retina Display Not supported");
    
    // Default texture format for PNG/BMP/TIFF/JPEG/GIF images
    // It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
    // You can change anytime.
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    // If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
    // On iPad HD  : "-ipadhd", "-ipad",  "-hd"
    // On iPad     : "-ipad", "-hd"
    // On iPhone HD: "-hd"
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    [sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
    [sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
    [sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
    [sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
    
    // Assume that PVR images have premultiplied alpha
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    // you are supposed to make the SCENE be your big beefcake
    // add an empty scene, so we can call replace from now on
    [director runWithScene:[CCScene node]];
    
    [self stop];
    
    return director;
}

+(void)runLayer:(CCLayer*)layer {
    CCDirectorIOS * director = [self shared];
	CCScene *scene = [CCScene node];
	[scene addChild:layer];
    [director replaceScene:scene];
    [self start];
}

+(void)unload {
    CCDirectorIOS * director = [self shared];
    CCScene * empty = [CCScene new];
    CCLayer * layer = [CCLayer new];
    [empty addChild:layer];
    [director replaceScene:empty];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stop];
    });
}

+(void)stop {
    CCDirectorIOS * director = [self shared];
    [director stopAnimation];
    [director pause];
 }

+(void)start {
    CCDirectorIOS * director = [self shared];
    [director stopAnimation];
    [director resume];
    [director startAnimation];
}

@end
