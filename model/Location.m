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
@synthesize hostname;
@synthesize port;
@synthesize username;
@synthesize password;
@synthesize directory;
@synthesize uid;

-(void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInt:type forKey:@"type"];
	[encoder encodeObject:hostname forKey:@"hostname"];
	[encoder encodeObject:port forKey:@"port"];
	[encoder encodeObject:username forKey:@"username"];
	[encoder encodeObject:password forKey:@"password"];
	[encoder encodeObject:directory forKey:@"directory"];	
	[encoder encodeObject:uid forKey:@"uid"];
}

- (id)copyWithZone:(NSZone *)zone 
{
    Location *copy = [[[self class] allocWithZone: zone] initWithType:type hostname:hostname username:username password:password directory:directory];
	[copy setPort:port];
	[copy setUid:uid];
    return copy;
}

-(id)initWithCoder:(NSCoder *)decoder
{
	type = [decoder decodeIntForKey:@"type"];
	hostname = [[decoder decodeObjectForKey:@"hostname"] retain];
	port = [[decoder decodeObjectForKey:@"port"] retain];
	username = [[decoder decodeObjectForKey:@"username"] retain];
	password = [[decoder decodeObjectForKey:@"password"] retain];
	directory = [[decoder decodeObjectForKey:@"directory"] retain];
	uid = [[decoder decodeObjectForKey:@"uid"] retain];
	return self;
}

- (void)setType:(int)newType
{
	if (newType != type)
	{
		type = newType;
		[self setDefaultPort];		
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
	}

	return self;
}

- (NSString *)description
{
	NSString *desc = [NSString stringWithFormat:@"<Location %@:%@>", hostname, directory];
	return desc;
}

- (void)setDefaultPort
{
	if (type == OWLocationTypeSFTP)
	{
		[self setPort:@"22"];
	}
	else
	{
		[self setPort:@"21"];
	}
}

- (void)dealloc
{
	[hostname release];
	[port release];
	[username release];
	[password release];
	[directory release];
	
	[super dealloc];
}

@end
