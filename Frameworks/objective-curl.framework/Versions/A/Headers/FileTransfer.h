//
//  FTPCommand.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import <stdio.h>
#import <sys/stat.h>
#import <curl/curl.h>

@interface FileTransfer : NSObject 
{
	NSString *localPath;
	NSString *remotePath;
	
	struct curl_slist *headers;
	struct curl_slist *postQuote;
	
	BOOL isEmptyDirectory;
	BOOL fileNotFound;
	
	int percentComplete;
	double totalBytes;
	double totalBytesUploaded;
}


@property(readwrite, copy) NSString *localPath;

@property(readwrite, copy) NSString *remotePath;

@property(readwrite, assign) BOOL isEmptyDirectory;

@property(readwrite, assign) BOOL fileNotFound;

@property(readwrite, assign) int percentComplete;

@property(readwrite, assign) double totalBytes;

@property(readwrite, assign) double totalBytesUploaded;


- (id)initWithLocalPath:(NSString *)aLocalPath remotePath:(NSString *)aRemotePath;

- (struct curl_slist *)headers;

- (void)appendHeader:(const char *)header;

- (void)cleanupHeaders;

- (struct curl_slist *)postQuote;

- (void)appendPostQuote:(const char *)quote;

- (void)cleanupPostQuotes;

- (FILE *)getHandle;

- (int)getInfo:(struct stat *)info;

- (NSString *)getEmptyFilePath;

+ (NSString *)emptyFilename;

@end
