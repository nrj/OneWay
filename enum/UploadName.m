//
//  UploadName.m
//  OneWay
//
//  Created by nrj on 3/7/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import "UploadName.h"
#import "NSString+Extras.h"

@implementation UploadName

+ (NSString *)nameForFileList:(NSArray *)fileList
{
	NSString *str;
	
	if ([fileList count] == 1)
	{
		str = [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:50];
	}
	else if ([fileList count] == 2)
	{
		str = [NSString stringWithFormat:@"%@ & 1 Other", 
					[[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:40]];
	}
	else
	{
		str = [NSString stringWithFormat:@"%@ & %d Others", 
					[[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:40], [fileList count]];	
	}
	
	return str;
}

@end
