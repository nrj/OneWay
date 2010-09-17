//
//  SystemVersion.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "SystemVersion.h"

@implementation SystemVersion


+ (void)alertSystemVersion {
	
	long versMaj, versMin, versBugFix;
	
	Gestalt(gestaltSystemVersionMajor, &versMaj);
	Gestalt(gestaltSystemVersionMinor, &versMin);
	Gestalt(gestaltSystemVersionBugFix, &versBugFix);
	
	NSBeginInformationalAlertSheet(@"MAC OS X ", @"OK", nil, nil, nil, nil, nil, nil, nil, [NSString stringWithFormat:@"%d %d %d", versMaj, versMin, versBugFix]);
}
	


+ (BOOL)isLeopard
{
	long versMaj, versMin;
	
	Gestalt(gestaltSystemVersionMajor, &versMaj);
	Gestalt(gestaltSystemVersionMinor, &versMin);
	
	return (versMaj == 10l && versMin == 5l);
}

+ (BOOL)isSnowLeopard
{
	long versMaj, versMin;
	
	Gestalt(gestaltSystemVersionMajor, &versMaj);
	Gestalt(gestaltSystemVersionMinor, &versMin);
	
	return (versMaj == 10l && versMin == 6l);
}

@end
