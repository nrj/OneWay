//
//  RemoteObject.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Foundation/Foundation.h>
#import "TransferStatus.h"


@interface RemoteObject : NSObject
{
	SecProtocolType protocol;
	NSString *protocolPrefix;
	NSString *hostname;
	int port;
	NSString *path;
	NSString *url;
	
	int clientType;

	NSString *username;
	NSString *password;

	BOOL usePublicKeyAuth;
	BOOL canUsePublicKeyAuth;
	NSString *privateKeyFile;
	NSString *publicKeyFile;
	
	TransferStatus status;
	BOOL connected;
	BOOL cancelled;
	
	NSString *name;
	NSString *statusMessage;
}


@property(readwrite, assign) SecProtocolType protocol;
@property(readwrite, copy) NSString *protocolPrefix;
@property(readwrite, copy) NSString *hostname;
@property(readwrite, assign) int port;
@property(readwrite, copy) NSString *path;
@property(readwrite, copy) NSString *url;

@property(readwrite, assign) int clientType;

@property(readwrite, copy) NSString *username;
@property(readwrite, copy) NSString *password;

@property(readwrite, assign) BOOL usePublicKeyAuth;
@property(readwrite, assign) BOOL canUsePublicKeyAuth;
@property(readwrite, copy) NSString *privateKeyFile;
@property(readwrite, copy) NSString *publicKeyFile;

@property(readwrite, assign) TransferStatus status;
@property(readwrite, assign) BOOL connected;
@property(readwrite, assign) BOOL cancelled;
/*
 * Note: These 2 properties are not used by the framework; use them as you wish.
 */
@property(readwrite, copy) NSString *name;
@property(readwrite, copy) NSString *statusMessage;


- (BOOL)hasAuthUsername;

- (BOOL)hasAuthPassword;

- (NSString *)uri;

@end
