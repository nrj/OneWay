//
//  PasswordSheet.m
//  OneWay
//
//  Created by nrj on 9/7/09.
//  Copyright 2009 cocoaism.com. All rights reserved.
//

#import "PasswordSheet.h"


@implementation PasswordSheet


@synthesize upload;
@synthesize numberInQueue;
@synthesize savePassword;


- (id)init
{
	if (self = [super initWithWindowNibName:@"PasswordSheet" owner:self])
	{
		[self setSavePassword:YES];
	}
	return self;
}


- (void)dealloc
{
	[upload release];
	[super dealloc];
}


- (void)windowDidBecomeKey:(NSNotification *)notification
{	
	[titleLabel setStringValue:[NSString stringWithFormat:@"Invalid Login for %@@%@", 
								[upload username], [upload hostname]]];
}


- (IBAction)closeSheetOK:(id)sender
{	
	[NSApp endSheet:[self window] returnCode:1];
	[[self window] orderOut:nil];
}


- (IBAction)closeSheetCancel:(id)sender
{
	[NSApp endSheet:[self window] returnCode:0];
	[[self window] orderOut:nil];
}

- (IBAction)closeSheetCancelAll:(id)sender
{
	[NSApp endSheet:[self window] returnCode:-1];
	[[self window] orderOut:nil];
}


@end
