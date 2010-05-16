//
//  SystemVersion.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "SystemVersion.h"


@implementation SystemVersion

+ (BOOL)isLeopard
{
    OSErr err;
    SInt32 versionMajor, versionMinor;
    
	if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr || (err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr)
	{
		NSLog(@"Unable to determine system version");
    }
    
    return (versionMajor == 10 && versionMinor == 5);
}

+ (BOOL)isSnowLeopard
{
    OSErr err;
    SInt32 versionMajor, versionMinor;
    
	if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr || (err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr)
	{
		NSLog(@"Unable to determine system version");
    }
    
    return (versionMajor == 10 && versionMinor == 6);
}

@end
