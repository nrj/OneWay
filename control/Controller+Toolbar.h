//
//  Controller+Toolbar.h
//  OneWay
//
//  Created by nrj on 9/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"


@interface Controller (Toolbar)

- (void)setupToolbar:(NSString *)identifier forWindow:(NSWindow *)theWindow;

@end
