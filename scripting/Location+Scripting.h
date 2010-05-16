//
//  Location+Scripting.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "Location.h"


@interface Location (Scripting)

- (NSScriptObjectSpecifier *)objectSpecifier;
- (void)queueTransfer:(NSScriptCommand*)command;
- (NSString *)locationName;

@end
