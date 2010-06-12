//
//  PasswordSheet.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>
#import "UploadSheet.h"

@class Upload;

@interface PasswordSheet : NSWindowController <UploadSheet> 
{
	Upload *upload;
	int numberInQueue;
	BOOL savePassword;
	
	IBOutlet NSTextField *titleLabel;
	IBOutlet NSTextField *passwordField;

	IBOutlet NSTextField *usernameLabel;
	IBOutlet NSTextField *passwordLabel;
	IBOutlet NSButton *usePublicKeyCheckbox;
}

@property(readwrite, retain) Upload *upload;
@property(readwrite, assign) int numberInQueue;
@property(readwrite, assign) BOOL savePassword;

- (IBAction)closeSheetOK:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;
- (IBAction)closeSheetCancelAll:(id)sender;

- (IBAction)usePublicKeyAuthPressed:(id)sender;

- (void)updateLabels;
- (void)updateTitle;

@end
