//
//  PasswordSheet.h
//  OneWay
//
//  Created by nrj on 9/7/09.
//  Copyright 2009 cocoaism.com. All rights reserved.
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
}

@property(readwrite, retain) Upload *upload;
@property(readwrite, assign) int numberInQueue;
@property(readwrite, assign) BOOL savePassword;

- (IBAction)closeSheetOK:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;
- (IBAction)closeSheetCancelAll:(id)sender;

@end
