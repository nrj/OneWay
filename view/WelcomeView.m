//
//  WelcomeView.m
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "WelcomeView.h"
#import "OWConstants.h"


@implementation WelcomeView

@synthesize relativeWindow;

- (id)initRelativeToWindow:(NSWindow *)aWindow
{
	if (self = [super initWithWindowNibName:@"WelcomeView" owner:self])
	{
		isPositioned = NO;
		
		[self setRelativeWindow:aWindow];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (IBAction)restartFinder:(id)sender
{
	NSLog(@"Restarting Finder.");
	
	NSString * scriptPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], OWRestartFinderScript];
	NSTask * task = [[[NSTask alloc] init] autorelease];
	
	[task setLaunchPath:@"/bin/sh"];
	[task setArguments:[NSArray arrayWithObject:scriptPath]];
	[task launch];
	[task waitUntilExit];
		
	[NSApp stopModal];
	
	[[self window] close];
}

- (void)windowDidUpdate:(NSNotification *)notification
{	
	if (!isPositioned)
	{
		NSRect relFrame = [relativeWindow frame];
		NSRect thisFrame = [[self window] frame];
		
		[[self window] setFrame:NSMakeRect(relFrame.origin.x + (relFrame.size.width / 2) - (thisFrame.size.width / 2),
										   relFrame.origin.y + (relFrame.size.height / 2) - (thisFrame.size.height / 2), 
										   thisFrame.size.width,
										   thisFrame.size.height) display:YES];
		
		isPositioned = YES;
	}
}


@end
