//
//  ProgressGradients.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>


@interface ProgressGradients : NSObject

+ (NSGradient *) progressGradientForRed: (CGFloat) redComponent green: (CGFloat) greenComponent blue: (CGFloat) blueComponent;

+ (NSGradient *) progressLightGrayGradient;

+ (NSGradient *) progressRedGradient;

+ (NSGradient *) progressLightGreenGradient;

+ (NSGradient *) progressBlueGradient;


@end
