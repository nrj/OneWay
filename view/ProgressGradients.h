//
//  ProgressGradients.h
//  OneWay
//
//  Created by nrj on 9/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ProgressGradients : NSObject

+ (NSGradient *) progressGradientForRed: (CGFloat) redComponent green: (CGFloat) greenComponent blue: (CGFloat) blueComponent;

+ (NSGradient *) progressLightGrayGradient;

+ (NSGradient *) progressRedGradient;

+ (NSGradient *) progressLightGreenGradient;

+ (NSGradient *) progressBlueGradient;


@end
