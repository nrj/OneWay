//
//  UploadSheet.h
//  OneWay
//
//  Created by nrj on 3/16/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
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
