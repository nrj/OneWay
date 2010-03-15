//
//  PasswordSheet.h
//  OneWay
//
//  Created by nrj on 9/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>

@class Upload;

@interface PasswordSheet : NSWindowController 
{
	Upload *upload;
	BOOL savePassword;
	
	IBOutlet NSTextField *titleLabel;
	IBOutlet NSTextField *passwordField;
}

@property(readwrite, assign) Upload *upload;
@property(readwrite, assign) BOOL savePassword;

- (IBAction)closeSheetOK:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;

@end
