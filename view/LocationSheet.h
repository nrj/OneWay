//
//  LocationSheet.h
//  OneWay
//
//  Created by nrj on 9/1/09.
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Location;

@interface LocationSheet : NSWindowController
{	
	IBOutlet NSTextField *messageLabel;
	IBOutlet NSButton *saveButton;
	IBOutlet NSButton *closeButton;
	IBOutlet NSPopUpButton *typeMenu;
	
	Location *location;
	NSArray *fileList;
	NSString *message;

	BOOL shouldShowSaveOption;
	BOOL shouldSaveLocation;

	NSColor *messageColor;
}

@property(readwrite, retain) Location *location;
@property(readwrite, retain) NSArray *fileList;
@property(readwrite, copy) NSString *message;
@property(readwrite, assign) BOOL shouldShowSaveOption;
@property(readwrite, assign) BOOL shouldSaveLocation;
@property(readwrite, retain) NSColor *messageColor;

- (IBAction)closeSheetOK:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;

@end
