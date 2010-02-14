//
//  ConnectionRecord+Scripting.h
//  OneWay
//
//  Created by nrj on 7/22/09.
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"

@class Location;

@interface Controller (Scripting)

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key;
- (unsigned int)countOfSavedLocations;
- (Location *)valueInSavedLocationsAtIndex:(unsigned int)index;
- (Location *)valueInSavedLocationsWithName:(NSString *)name;

@end
