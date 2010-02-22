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

@synthesize message;
@synthesize location;
@synthesize fileList;
@synthesize shouldShowSaveOption;
@synthesize shouldSaveLocation;
@synthesize messageIsError;
@synthesize messageColor;

- (id)init
{
	if (self = [super initWithWindowNibName:@"LocationSheet"])
	{
		message = [[NSString alloc] initWithFormat:@""];
		messageColor = [NSColor darkGrayColor];
	}
	return self;
}


- (void)setMessageIsError:(BOOL)isError
{
	if (isError)
	{
		[self setMessageColor:[NSColor redColor]];
	}
	else
	{
		[self setMessageColor:[NSColor darkGrayColor]];
	}

	messageIsError = isError;
}


- (void)dealloc
{
	[message release], message = nil;
	[location release], location = nil;
	[fileList release], fileList = nil;
	[super dealloc];
}


- (void)windowDidBecomeKey:(NSNotification *)notification
{	
	[messageLabel setStringValue:message];
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
