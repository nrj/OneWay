//
//  FailureSheet.h
//  OneWay
//
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>
#import "UploadSheet.h"

@interface FailureSheet : NSWindowController <UploadSheet>
{
	Upload *upload;
	int numberInQueue;
	IBOutlet NSTextView *textView;
}

@property(readwrite, retain) Upload *upload;
@property(readwrite, assign) int numberInQueue;

- (IBAction)closeSheetTryAgain:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;
- (IBAction)closeSheetCancelAll:(id)sender;

@end
