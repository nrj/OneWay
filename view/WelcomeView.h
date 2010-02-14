//
//  WelcomeView.h
//  OneWay
//
//  Created by nrj on 10/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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
