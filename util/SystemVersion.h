//
//  SystemVersion.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface SystemVersion : NSObject 

+ (void)alertSystemVersion;
+ (BOOL)isLeopard;
+ (BOOL)isSnowLeopard;

@end
