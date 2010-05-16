//
//  FailureSheet.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "FailureSheet.h"


@implementation FailureSheet

@synthesize upload;
@synthesize numberInQueue;

- (id)init
{
	if (self = [super initWithWindowNibName:@"FailureSheet" owner:self])
	{

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
	[textView setString:[upload statusMessage]];
}

- (IBAction)closeSheetTryAgain:(id)sender
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
