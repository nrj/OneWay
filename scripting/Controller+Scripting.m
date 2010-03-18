//
//  ConnectionRecord+Scripting.m
//  OneWay
//
//  Created by nrj on 7/22/09.
//  Copyright 2009. All rights reserved.
//

#import "Controller+Scripting.h"
#import "Location.h"


@implementation Controller (Scripting)


- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key 
{
    if ([key isEqualToString: @"savedLocations"]) 
	{
		return YES;
	}
	return NO; 
}


- (unsigned int)countOfSavedLocations 
{
	NSLog(@"Total Locations = %d", [savedLocations count]);
	return [savedLocations count]; 
}


- (Location *)objectInSavedLocationsAtIndex:(unsigned int)index
{
	NSLog(@"Getting Location at Index %d", index);
	return [savedLocations objectAtIndex:index];
}


- (void) returnError:(int)n string:(NSString*)s { 
    NSScriptCommand* c = [NSScriptCommand currentCommand]; 
    [c setScriptErrorNumber:n]; 
    if (s) [c setScriptErrorString:s]; 
} 



@end
