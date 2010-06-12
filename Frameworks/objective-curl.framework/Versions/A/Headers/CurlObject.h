//
//  CurlObject.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Foundation/Foundation.h>
#import "curl-ssh-patched.h"
#include <sys/stat.h>

@class RemoteObject;

@interface CurlObject : NSObject
{	
	id delegate;

	SecProtocolType protocol;
	
	BOOL verbose;
	BOOL showProgress;
	
	NSOperationQueue *operationQueue;
}

@property(readwrite, assign) id delegate;
@property(readwrite, assign) SecProtocolType protocol;
@property(readwrite, assign) BOOL verbose;
@property(readwrite, assign) BOOL showProgress;

+ (NSString *)libcurlVersion;

- (CURL *)newHandle;

@end