//
//  LocationSheet.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "OWConstants.h"
#import "LocationSheet.h"
#import "Location.h"
#import "NSString+Truncate.h"


@implementation LocationSheet


@synthesize message;

@synthesize messageColor;

@synthesize location;

@synthesize fileList;

@synthesize shouldShowSaveOption;

@synthesize shouldSaveLocation;

@synthesize shouldShowMoreOptions;


- (id)init
{
	if (self = [super initWithWindowNibName:@"LocationSheet"])
	{
		message = [[NSString alloc] initWithFormat:@""];
		messageColor = [NSColor darkGrayColor];
	}
	return self;
}


- (void)dealloc
{
	[message release], message = nil;
	[location release], location = nil;
	[fileList release], fileList = nil;
	[super dealloc];
}


- (void)setLocation:(Location *)aLocation
{
	if (aLocation != location)
	{
		[location release];
		location = [aLocation retain];
		
		[messageLabel setStringValue:message];
		[moreButton setState:[location webAccessible]];
		
		[self updatePasswordLabel];
		
		[self moreOptionsPressed:moreButton];
	}
}


- (void)awakeFromNib
{
	[moreButton setState:[location webAccessible]];
	
	[self moreOptionsPressed:moreButton];	
	
	[self updatePasswordLabel];
}

- (IBAction)locationTypeSelected:(id)sender
{
	int selection = [sender indexOfItem:[sender selectedItem]];

	if (selection == OWLocationTypeFTP)
	{
		[location setUsePublicKeyAuth:NO];
		[location setPrivateKeyFile:nil];
		[location setPublicKeyFile:nil];
	}
}

- (IBAction)moreOptionsPressed:(id)sender 
{ 
	NSWindow *window = [sender window]; 
	NSRect frame = [window frame];
	CGFloat sizeChange = [moreOptionsBox frame].size.height + 10; 
	switch ([sender state]) 
	{ 
		case NSOnState:
			if ([moreOptionsBox isHidden])
			{
				[moreOptionsBox setHidden:NO];
				frame.size.height += sizeChange;
				frame.origin.y -= sizeChange; 
			}
			break; 
		
		case NSOffState: 
			if (![moreOptionsBox isHidden])
			{
				[moreOptionsBox setHidden:YES];
				frame.size.height -= sizeChange;
				frame.origin.y += sizeChange;
			}
			break; 

		default: 
			break; 
	} 
	
	[window setFrame:frame display:YES animate:YES]; 
} 


- (IBAction)usePublicKeyAuthPressed:(id)sender
{	
	if ([sender state] == NSOnState)
	{		
		NSOpenPanel* openDlg = [NSOpenPanel openPanel];
		
		[openDlg setCanChooseFiles:YES];
		[openDlg setCanChooseDirectories:NO];
		[openDlg setTitle:@"Select Private Key"];
		
		NSString *sshDir = [@"~/.ssh" stringByExpandingTildeInPath];
		
		if ([openDlg runModalForDirectory:sshDir file:nil] == NSOKButton)
		{
			if ([[openDlg filenames] count] == 1)
			{
				NSString *privateKeyPath = [[openDlg filenames] objectAtIndex:0];
				NSString *publicKeyPath = [NSString stringWithFormat:@"%@.pub", privateKeyPath];
				
				[location setUsePublicKeyAuth:YES];
				[location setPrivateKeyFile:privateKeyPath];
				[location setPublicKeyFile:publicKeyPath];
			}
		}		
	}
	else
	{
		[location setUsePublicKeyAuth:NO];
		[location setPrivateKeyFile:nil];
		[location setPublicKeyFile:nil];		
	}
	
	[self updatePasswordLabel];
}


- (void)updatePasswordLabel
{
	if ([location usePublicKeyAuth])
	{
		[passwordLabel setStringValue:PASSPHRASE_LABEL];
	}
	else
	{
		[passwordLabel setStringValue:PASSWORD_LABEL];	
	}	
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


@end
