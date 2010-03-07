//
//  StatusMessage.m
//  OneWay
//
//  Created by nrj on 2/21/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import "StatusMessage.h"
#import "NSString+Extras.h"

@implementation StatusMessage


+ (NSString *)newLocationMessage
{
	return @"New Menu Item";	
}


+ (NSString *)editLocationMessage
{
	return @"Edit Menu Item";
}


+ (NSString *)uploadFilesToNewLocationMessage:(NSArray *)fileList
{
	NSString *str;
	
	if ([fileList count] == 1)
	{
		str = [NSString stringWithFormat:@"Uploading \"%@\" to New Location", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:42]];
	}
	else if ([fileList count] == 2)
	{
		str = [NSString stringWithFormat:@"Uploading \"%@\" & 1 other to New Location", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:34]];
	}
	else if ([fileList count] < 99)
	{
		str = [NSString stringWithFormat:@"Uploading \"%@\" & %d others to New Location", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:33], [fileList count] - 1];
	}
	else
	{
		str = [NSString stringWithFormat:@"Uploading \"%@\" & %d others to New Location", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:32], [fileList count] - 1];
	}

	return str;
}


@end
