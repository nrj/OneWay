//
//  SystemVersion.m
//  OneWay
//
//  Created by nrj on 3/14/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
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
