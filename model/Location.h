//
//  Location.h
//  OneWay
//
//  Created by nrj on 7/22/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject <NSCoding>
{
	int type;
	NSString *hostname;
	NSString *port;
	NSString *username;
	NSString *password;
	NSString *directory;
	NSString *uid;
}

@property(nonatomic, readwrite, assign) int type;
@property(nonatomic, readwrite, copy) NSString *hostname;
@property(nonatomic, readwrite, copy) NSString *port;
@property(nonatomic, readwrite, copy) NSString *username;
@property(nonatomic, readwrite, copy) NSString *password;
@property(nonatomic, readwrite, copy) NSString *directory;
@property(nonatomic, readwrite, copy) NSString *uid;

- (void)encodeWithCoder:(NSCoder *)encoder;

- (id)initWithCoder:(NSCoder *)decoder;

- (id)initWithType:(int)aType hostname:(NSString *)aHostname username:(NSString *)aUsername password:(NSString *)aPassword directory:(NSString *)aDirectory;

- (void)setDefaultPort;

@end
