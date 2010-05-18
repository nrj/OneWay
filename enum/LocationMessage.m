//
//  LocationMessage.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "LocationMessage.h"
#import "NSString+Truncate.h"

@implementation LocationMessage


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
