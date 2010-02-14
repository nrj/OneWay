//
//  PasswordSheet.h
//  OneWay
//
//  Created by nrj on 9/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PasswordSheet : NSWindowController 
{
	IBOutlet NSTextField *titleLabel;
	IBOutlet NSTextField *passwordField;
	BOOL shouldSaveInKeychain;
	
	NSString *titleString;
	NSString *password;
}

@property(readwrite, copy) NSString *password;
@property(readwrite, copy) NSString *titleString;
@property(readwrite, assign) BOOL shouldSaveInKeychain;


- (IBAction)closeSheetOK:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;

@end
