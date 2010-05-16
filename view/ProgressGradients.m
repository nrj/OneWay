//
//  ProgressGradients.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "ProgressGradients.h"


@implementation ProgressGradients

+ (NSGradient *) progressGradientForRed: (CGFloat) redComponent green: (CGFloat) greenComponent blue: (CGFloat) blueComponent
{
    NSColor * baseColor = [NSColor colorWithCalibratedRed: redComponent green: greenComponent blue: blueComponent alpha: 1.0];
    
    NSColor * color2 = [NSColor colorWithCalibratedRed: redComponent * 0.95 green: greenComponent * 0.95 blue: blueComponent * 0.95
												 alpha: 1.0];
    
    NSColor * color3 = [NSColor colorWithCalibratedRed: redComponent * 0.85 green: greenComponent * 0.85 blue: blueComponent * 0.85
												 alpha: 1.0];
    
    NSGradient * progressGradient = [[NSGradient alloc] initWithColorsAndLocations: baseColor, 0.0, color2, 0.5, color3, 0.5,
									 baseColor, 1.0, nil];
    return [progressGradient autorelease];
}

NSGradient * fProgressLightGrayGradient = nil;
+ (NSGradient *) progressLightGrayGradient
{
    if (!fProgressLightGrayGradient)
        fProgressLightGrayGradient = [[[self class] progressGradientForRed: 0.87f green: 0.87f blue: 0.87f] retain];
    return fProgressLightGrayGradient;
}

NSGradient * fProgressBlueGradient = nil;
+ (NSGradient *) progressBlueGradient
{
    if (!fProgressBlueGradient)
        fProgressBlueGradient = [[[self class] progressGradientForRed: 0.35f green: 0.67f blue: 0.98f] retain];
    return fProgressBlueGradient;
}

NSGradient * fProgressLightGreenGradient = nil;
+ (NSGradient *) progressLightGreenGradient
{
    if (!fProgressLightGreenGradient)
        fProgressLightGreenGradient = [[[self class] progressGradientForRed: 0.62f green: 0.99f blue: 0.58f] retain];
    return fProgressLightGreenGradient;
}


NSGradient * fProgressRedGradient = nil;
+ (NSGradient *) progressRedGradient
{
    if (!fProgressRedGradient)
        fProgressRedGradient = [[[self class] progressGradientForRed: 0.902f green: 0.439f blue: 0.451f] retain];
    return fProgressRedGradient;
}


@end
