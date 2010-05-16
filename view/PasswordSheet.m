//
//  PasswordSheet.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
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
