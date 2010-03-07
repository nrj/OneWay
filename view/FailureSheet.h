//
//  FailureSheet.h
//  OneWay
//
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>


@interface FailureSheet : NSWindowController 
{
	Upload *upload;
	
	IBOutlet NSTextView *textView;
}

@property(readwrite, assign) Upload *upload;

- (IBAction)closeSheetTryAgain:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;

@end
