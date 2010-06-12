//
//  RemoteFolder.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Foundation/Foundation.h>
#import "RemoteObject.h"

@interface RemoteFolder : RemoteObject
{	
	NSArray *files;
	
	BOOL forceReload;
}

@property(readwrite, retain) NSArray *files;
@property(readwrite, assign) BOOL forceReload;

@end
