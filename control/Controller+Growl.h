//
//  Controller+Growl.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"

@interface Controller (NSObject)

- (void)initGrowl;

- (void)displayGrowlNotification:(NSString *)title message:(NSString *)message;

@end
