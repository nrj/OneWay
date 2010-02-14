//
//  LocationSheet.h
//  OneWay
//
//  Created by nrj on 9/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Location;

@interface LocationSheet : NSWindowController
{	
	IBOutlet NSTextField *subtitleLabel;
	IBOutlet NSButton *saveButton;
	IBOutlet NSButton *closeButton;
	IBOutlet NSPopUpButton *typeMenu;
	
	Location *location;
	NSArray *fileList;
	NSString *subtitle;

	BOOL shouldSaveLocation;
	BOOL shouldShowSaveOption;
}

@property(readwrite, retain) Location *location;
@property(readwrite, retain) NSArray *fileList;
@property(readwrite, copy) NSString *subtitle;
@property(readwrite, assign) BOOL shouldSaveLocation;
@property(readwrite, assign) BOOL shouldShowSaveOption;

- (IBAction)closeSheetOK:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;

@end
