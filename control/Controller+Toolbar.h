//
//  Controller+Toolbar.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"


@interface Controller (Toolbar)

- (void)setupToolbar:(NSString *)identifier forWindow:(NSWindow *)theWindow;

- (NSSegmentedControl *)newToggleViewControl;

@end
