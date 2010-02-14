//
//  PasswordSheet.m
//  OneWay
//
//  Created by nrj on 9/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PasswordSheet.h"


@implementation PasswordSheet

@synthesize password;
@synthesize titleString;
@synthesize shouldSaveInKeychain;

- (id)init
{
	if (self = [super initWithWindowNibName:@"PasswordSheet" owner:self])
	{
		// Set Defaults
		titleString = [[NSString alloc] initWithFormat:@""];
		[self setShouldSaveInKeychain:YES];
	}
	return self;
}

- (void)dealloc
{
	[titleString release];
	[password release];
	[super dealloc];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{	
	[titleLabel setStringValue:titleString];
}

- (IBAction)closeSheetOK:(id)sender
{	
	password = [NSString stringWithString:[passwordField stringValue]];
	
	[NSApp endSheet:[self window] returnCode:1];
}

- (IBAction)closeSheetCancel:(id)sender
{
	[NSApp endSheet:[self window] returnCode:0];
}


@end
