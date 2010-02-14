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
	return [savedLocations count]; 
}


- (Location *)valueInSavedLocationsAtIndex:(unsigned int)index
{
	return [savedLocations objectAtIndex:index];
}


- (Location *)valueInSavedLocationsWithName:(NSString*)name 
{
	int i, u = [savedLocations count];
	for (i = 0; i < u; i++)
	{
		Location *location = (Location *)[savedLocations objectAtIndex:i];
		if ([[location uid] caseInsensitiveCompare:name] == NSOrderedSame)
			return [savedLocations objectAtIndex:i];
	}
	return nil;
}


@end
