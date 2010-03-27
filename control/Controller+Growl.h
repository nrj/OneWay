//
//  Controller+Growl.h
//  OneWay
//
//  Created by nrj on 3/22/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"

@interface Controller (NSObject)

- (void)initGrowl;

- (void)displayGrowlNotification:(NSString *)title message:(NSString *)message;

@end
