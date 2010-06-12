//
//  CurlFTP.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Foundation/Foundation.h>
#import "CurlObject.h"
#import "CurlClient.h"


@class Upload, RemoteFolder;


@interface CurlFTP : CurlObject <CurlClient>
{
	NSMutableDictionary *directoryListCache;
}

- (NSString *)protocolPrefix;
- (int)defaultPort;

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username;
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password;
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory;
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory port:(int)port;
- (void)upload:(Upload *)record;

static size_t handleDirectoryList(void *ptr, size_t size, size_t nmemb, NSMutableArray *list);

- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host;
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload;
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload port:(int)port;

@end
