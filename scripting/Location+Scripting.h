//
//  Location+Scripting.h
//  OneWay
//
//  Created by nrj on 7/22/09.
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Location.h"


@interface Location (Scripting)

- (NSScriptObjectSpecifier *)objectSpecifier;
- (void)queueTransfer:(NSScriptCommand*)command;
- (NSString *)locationName;

@end
