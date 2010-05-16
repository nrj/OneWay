//
//  Controller+Growl.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "Controller+Growl.h"


@implementation Controller (Growl)

- (void)initGrowl
{
	NSString *growlPath = [[[NSBundle mainBundle] privateFrameworksPath] 
								stringByAppendingPathComponent:@"Growl.framework"];

	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
	
	if (growlBundle && [growlBundle load]) 
	{
		NSLog(@"Growl Loaded");
		
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	else 
	{
		NSLog(@"ERROR: Could not load Growl.framework");
	}
}

- (void)displayGrowlNotification:(NSString *)title message:(NSString *)message
{	
	[GrowlApplicationBridge notifyWithTitle:title
								description:message
						   notificationName:title
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:[NSDate date]];
}

@end
