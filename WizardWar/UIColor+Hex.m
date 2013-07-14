//
//  UIColor+Hex.m
//  WizardWar
//
//  Created by Sean Hess on 7/14/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "UIColor+Hex.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation UIColor (Hex)

+(UIColor*)colorFromRGB:(NSUInteger)rgb {
    return UIColorFromRGB(rgb);
}

- (NSUInteger)RGB
{
    float red, green, blue;
    if ([self getRed:&red green:&green blue:&blue alpha:NULL])
    {
        NSUInteger redInt = (NSUInteger)(red * 255 + 0.5);
        NSUInteger greenInt = (NSUInteger)(green * 255 + 0.5);
        NSUInteger blueInt = (NSUInteger)(blue * 255 + 0.5);
        
        return (redInt << 16) | (greenInt << 8) | blueInt;
    }
    
    return 0;
}

@end
