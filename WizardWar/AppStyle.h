//
//  FontsStyle.h
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FONT_LOVEYA @"LoveYaLikeASister"
#define FONT_LOVEYA_BOLD @"LoveYaLikeASisterSolid"
#define FONT_COMIC_ZINE @"ComicZineOT"
#define FONT_COMIC_ZINE_SOLID @"ComicZineSolid-Regular"

@interface AppStyle : NSObject

+(void)customizeUIKitStyles;
+(UIColor*)blueNavColor;
+(UIImage*)blueNavColorImage;
+(UIColor*)greenGrassColor;
+(UIColor*)yellowButtonTextColor;
+(UIImage *)imageWithColor:(UIColor *)color;

@end
