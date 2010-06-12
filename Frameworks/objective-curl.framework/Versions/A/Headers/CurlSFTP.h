//
//  CurlSFTP.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "CurlFTP.h"
#import "CurlClient.h"

extern int const DEFAULT_SFTP_PORT;

extern NSString * const DEFAULT_KNOWN_HOSTS;

extern NSString * const SFTP_PROTOCOL_PREFIX;


@interface CurlSFTP : CurlFTP <CurlClient>
{
	NSString *knownHostsFile;
}

@property(readwrite, copy) NSString *knownHostsFile;

@end
