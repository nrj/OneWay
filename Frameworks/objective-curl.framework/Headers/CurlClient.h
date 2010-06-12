//
//  CurlClient.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//


@class Upload;

@protocol CurlClient

- (SecProtocolType)protocol;

- (int)clientType;

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (void)setVerbose:(BOOL)verbose;
- (BOOL)verbose;

- (void)setShowProgress:(BOOL)showProgress;
- (BOOL)showProgress;

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username;

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password;

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory;

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory port:(int)port;

- (void)upload:(Upload *)record;

- (CURL *)newHandle;

@end
