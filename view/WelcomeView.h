//
//  WelcomeView.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>


@interface WelcomeView : NSWindowController 
{
	NSWindow *relativeWindow;
	
	BOOL isPositioned;
}

@property(readwrite, assign) NSWindow *relativeWindow;

- (id)initRelativeToWindow:(NSWindow *)aWindow;

- (IBAction)restartFinder:(id)sender;

@end
