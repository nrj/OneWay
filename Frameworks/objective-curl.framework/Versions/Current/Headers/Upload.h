//
//  Upload.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Foundation/Foundation.h>
#import "RemoteObject.h"

@class FileTransfer;


@interface Upload : RemoteObject
{	
	NSArray *localFiles;
	
	NSArray *transfers;
	
	FileTransfer *currentTransfer;
	
	int progress;
	
	int totalFiles;
	
	int totalFilesUploaded;
	
	double totalBytes;
	
	double totalBytesUploaded;
	
	double lastBytesUploaded;
	
	double bytesPerSecond;
	
	double secondsRemaining;
}


@property(readwrite, retain) NSArray *localFiles;

@property(readwrite, retain) NSArray *transfers;

@property(readwrite, assign) FileTransfer *currentTransfer;

@property(readwrite, assign) int progress;

@property(readwrite, assign) int totalFiles;

@property(readwrite, assign) int totalFilesUploaded;

@property(readwrite, assign) double totalBytes;

@property(readwrite, assign) double totalBytesUploaded;

@property(readwrite, assign) double lastBytesUploaded;

@property(readwrite, assign) double bytesPerSecond;

@property(readwrite, assign) double secondsRemaining;


- (BOOL)isActive;


@end
