//
//  LocationSheet.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>

@class Location;

@interface LocationSheet : NSWindowController
{	
	IBOutlet NSTextField *messageLabel;
	IBOutlet NSButton *saveButton;
	IBOutlet NSButton *closeButton;
	IBOutlet NSPopUpButton *typeMenu;
	IBOutlet NSButton *moreButton;
	IBOutlet NSBox *moreOptionsBox;
	IBOutlet NSButton *usePublicKeyCheckbox;

	IBOutlet NSTextField *directoryLabel;
	IBOutlet NSTextField *usernameLabel;
	IBOutlet NSTextField *passwordLabel;

	Location *location;
	NSArray *fileList;
	NSString *message;

	
	BOOL shouldShowSaveOption;
	BOOL shouldSaveLocation;
	BOOL shouldShowMoreOptions;

	NSColor *messageColor;
}

@property(readwrite, retain) Location *location;
@property(readwrite, retain) NSArray *fileList;
@property(readwrite, copy) NSString *message;
@property(readwrite, assign) BOOL shouldShowSaveOption;
@property(readwrite, assign) BOOL shouldSaveLocation;
@property(readwrite, assign) BOOL shouldShowMoreOptions;
@property(readwrite, retain) NSColor *messageColor;

- (IBAction)closeSheetOK:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;
- (IBAction)locationTypeSelected:(id)sender;
- (IBAction)moreOptionsPressed:(id)sender;
- (IBAction)usePublicKeyAuthPressed:(id)sender;

- (void)updateLocationLabels;

@end
