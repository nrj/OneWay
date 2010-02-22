//
//  FailureSheet.h
//  OneWay
//
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Upload;

@interface FailureSheet : NSWindowController 
{
	NSString *message;

	Upload *upload;
	
	IBOutlet NSTextView *textView;
}

@property(readwrite, copy) NSString *message;
@property(readwrite, assign) Upload *upload;

- (IBAction)closeSheetTryAgain:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;

@end
