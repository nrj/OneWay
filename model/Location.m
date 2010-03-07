//
//  Location.m
//  OneWay	
//
//  Created by nrj on 7/22/09.
//  Copyright 2009. All rights reserved.
//

#import "Location.h"
#import "NSString+UUID.h"
#import "OWConstants.h"


@implementation Location

@synthesize type;
@synthesize protocol;
@synthesize hostname;
@synthesize port;
@synthesize username;
@synthesize password;
@synthesize directory;
@synthesize uid;
@synthesize savePassword;


- (id)copyWithZone:(NSZone *)zone 
{
    Location *copy = [[self class] allocWithZone:zone];

	[copy setType:type];
	[copy setProtocol:protocol];
	[copy setHostname:hostname];
	[copy setPort:port];
	[copy setUsername:username];
	[copy setPassword:password];
	[copy setDirectory:directory];
	[copy setUid:uid];
	[copy setSavePassword:savePassword];

    return copy;
}


- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInt:type forKey:@"type"];
	[encoder encodeInt32:protocol forKey:@"protocol"];
	[encoder encodeObject:hostname forKey:@"hostname"];
	[encoder encodeInt:port forKey:@"port"];
	[encoder encodeObject:username forKey:@"username"];
	[encoder encodeObject:directory forKey:@"directory"];	
	[encoder encodeObject:uid forKey:@"uid"];
	[encoder encodeBool:savePassword forKey:@"savePassword"];
}


- (id)initWithCoder:(NSCoder *)decoder
{
	type = [decoder decodeIntForKey:@"type"];
	protocol = [decoder decodeIntForKey:@"protocol"];
	hostname = [[decoder decodeObjectForKey:@"hostname"] retain];
	port = [decoder decodeIntForKey:@"port"];
	username = [[decoder decodeObjectForKey:@"username"] retain];
	directory = [[decoder decodeObjectForKey:@"directory"] retain];
	uid = [[decoder decodeObjectForKey:@"uid"] retain];
	savePassword = [decoder decodeBoolForKey:@"savePassword"];
	return self;
}


- (void)setType:(int)newType
{
	if (newType != type)
	{
		type = newType;
		[self setProtocolDefaults];		
	}
}


- (id)initWithType:(int)aType hostname:(NSString *)aHostname username:(NSString *)aUsername password:(NSString *)aPassword directory:(NSString *)aDirectory
{		
	if (self = [super init]) 
	{
		[self setUid:[NSString stringWithNewUUID]];
		[self setType:aType];
		[self setHostname:aHostname];
		[self setUsername:aUsername];
		[self setPassword:aPassword];
		[self setDirectory:aDirectory];
		[self setSavePassword:YES];
		[self setProtocolDefaults];
	}

	return self;
}


- (NSString *)description
{
	return [NSString stringWithFormat:@"<Location %@:%@>", hostname, directory];
}


- (void)setProtocolDefaults
{
	if (type == OWLocationTypeSFTP)
	{
		[self setProtocol:kSecProtocolTypeSSH];
		[self setPort:22];
	}
	else
	{
		[self setProtocol:kSecProtocolTypeFTP];
		[self setPort:21];
	}
}

- (void)dealloc
{
	[hostname release], hostname = nil;
	[username release], username = nil;
	[password release], password = nil;
	[directory release], directory = nil;
	[uid release], uid = nil;
	
	[super dealloc];
}

@end
