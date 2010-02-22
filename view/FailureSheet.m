//
//  FailureSheet.m
//  OneWay
//
//  Copyright 2009. All rights reserved.
//

#import "FailureSheet.h"


@implementation FailureSheet

@synthesize message;
@synthesize upload;

- (id)init
{
	if (self = [super initWithWindowNibName:@"FailureSheet" owner:self])
	{
		message = @"";
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{	
	[textView setString:message];
}

- (IBAction)closeSheetTryAgain:(id)sender
{	
	[NSApp endSheet:[self window] returnCode:1];
}

- (IBAction)closeSheetCancel:(id)sender
{
	[NSApp endSheet:[self window] returnCode:0];
}


@end
