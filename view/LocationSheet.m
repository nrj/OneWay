//
//  LocationSheet.m
//  OneWay
//
//  Created by nrj on 9/1/09.
//  Copyright 2009. All rights reserved.
//

#import "LocationSheet.h"
#import "Location.h"
#import "NSString+Truncate.h"


@implementation LocationSheet

@synthesize subtitle;
@synthesize location;
@synthesize fileList;
@synthesize shouldShowSaveOption;
@synthesize shouldSaveLocation;


- (id)init
{
	if (self = [super initWithWindowNibName:@"LocationSheet"])
	{
		subtitle = [[NSString alloc] initWithFormat:@""];
	}
	return self;
}


- (void)reset
{
	[subtitle release], subtitle = nil;
	[location release], location = nil;
	[fileList release], fileList = nil;
	
	[self setShouldSaveLocation:NO];
	[self setShouldShowSaveOption:NO];
}


- (void)setFileList:(NSArray *)list
{
	if (list != fileList)
	{
		[fileList release];
		fileList = [list retain];

		// Create a subtitle string
		NSString *str;
		if ([fileList count] == 1)
		{
			str = [NSString stringWithFormat:@"Upload \"%@\"", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:25]];
		}
		else if ([fileList count] == 2)
		{
			str = [NSString stringWithFormat:@"Upload \"%@\" & 1 other", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:17]];
		}
		else if ([fileList count] < 99)
		{
			str = [NSString stringWithFormat:@"Upload \"%@\" & %d others", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:16], [fileList count] - 1];
		}
		else
		{
			str = [NSString stringWithFormat:@"Upload  \"%@\" & %d others", [[[fileList objectAtIndex:0] lastPathComponent] stringWithTruncatingToLength:15], [fileList count] - 1];		
		}
		
		[self setSubtitle:str];
	}
}

- (void)dealloc
{
	[subtitle release], subtitle = nil;
	[location release], location = nil;
	[fileList release], fileList = nil;
	[super dealloc];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{	
	[subtitleLabel setStringValue:subtitle];
}

- (IBAction)closeSheetOK:(id)sender
{	
	[NSApp endSheet:[self window] returnCode:1];
}

- (IBAction)closeSheetCancel:(id)sender
{
	[NSApp endSheet:[self window] returnCode:0];
}

@end
