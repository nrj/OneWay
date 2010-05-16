//
//  UploadSheet.h
//  OneWay
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>

@class Upload;

@protocol UploadSheet

- (void)setUpload:(Upload *)record;
- (Upload *)upload;

- (void)setNumberInQueue:(int)number;
- (int)numberInQueue;

- (NSWindow *)window;

@end
