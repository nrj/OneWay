//
//  ConnectionRecord+Scripting.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"

@class Location;

@interface Controller (Scripting)

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key;
- (unsigned int)countOfSavedLocations;
- (Location *)objectInSavedLocationsAtIndex:(unsigned int)index;

@end
