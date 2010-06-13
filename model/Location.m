//
//  Location.m
//  OneWay	
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
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
@synthesize privateKeyFile;
@synthesize publicKeyFile;
@synthesize directory;
@synthesize baseUrl;
@synthesize uid;
@synthesize savePassword;
@synthesize webAccessible;
@synthesize usePublicKeyAuth;


- (id)copyWithZone:(NSZone *)zone 
{
    Location *copy = [[self class] allocWithZone:zone];

	[copy setType:type];
	[copy setProtocol:protocol];
	[copy setHostname:hostname];
	[copy setPort:port];
	[copy setUsername:username];
	[copy setPassword:password];
	[copy setPrivateKeyFile:privateKeyFile];
	[copy setPublicKeyFile:publicKeyFile];
	[copy setDirectory:directory];
	[copy setBaseUrl:baseUrl];
	[copy setUid:uid];
	[copy setSavePassword:savePassword];
	[copy setWebAccessible:webAccessible];
	[copy setUsePublicKeyAuth:usePublicKeyAuth];

    return copy;
}


- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInt:type forKey:@"type"];
	[encoder encodeInt32:protocol forKey:@"protocol"];
	[encoder encodeObject:hostname forKey:@"hostname"];
	[encoder encodeInt:port forKey:@"port"];
	[encoder encodeObject:username forKey:@"username"];
	[encoder encodeObject:privateKeyFile forKey:@"privateKeyFile"];
	[encoder encodeObject:publicKeyFile forKey:@"publicKeyFile"];
	[encoder encodeObject:directory forKey:@"directory"];
	[encoder encodeObject:baseUrl forKey:@"baseUrl"];
	[encoder encodeObject:uid forKey:@"uid"];
	[encoder encodeBool:savePassword forKey:@"savePassword"];
	[encoder encodeBool:webAccessible forKey:@"webAccessible"];
	[encoder encodeBool:usePublicKeyAuth forKey:@"usePublicKeyAuth"];
}


- (id)initWithCoder:(NSCoder *)decoder
{
	type = [decoder decodeIntForKey:@"type"];
	protocol = [decoder decodeIntForKey:@"protocol"];
	hostname = [[decoder decodeObjectForKey:@"hostname"] retain];
	port = [decoder decodeIntForKey:@"port"];
	username = [[decoder decodeObjectForKey:@"username"] retain];
	privateKeyFile = [[decoder decodeObjectForKey:@"privateKeyFile"] retain];
	publicKeyFile = [[decoder decodeObjectForKey:@"publicKeyFile"] retain];
	directory = [[decoder decodeObjectForKey:@"directory"] retain];
	baseUrl = [[decoder decodeObjectForKey:@"baseUrl"] retain];
	uid = [[decoder decodeObjectForKey:@"uid"] retain];
	savePassword = [decoder decodeBoolForKey:@"savePassword"];
	webAccessible = [decoder decodeBoolForKey:@"webAccessible"];
	usePublicKeyAuth = [decoder decodeBoolForKey:@"usePublicKeyAuth"];
	
	return self;
}


- (void)setType:(int)value
{
	if (value != type)
	{
		type = value;
		[self setLocationDefaults];
	}
}

- (void)setWebAccessible:(BOOL)value
{
	if (value != webAccessible)
	{
		webAccessible = value;
		[self guessBaseUrl];
	}
}


- (void)setDirectory:(NSString *)value
{
	if (value != directory) {
			
		[directory release];
		directory = [value copy];
		
		if (webAccessible) {
			[self guessBaseUrl];
		}
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
		[self setWebAccessible:NO];
		[self setUsePublicKeyAuth:NO];
		[self setLocationDefaults];
	}

	return self;
}


- (NSString *)description
{
	return [NSString stringWithFormat:@"<Location %@/%@>", hostname, directory];
}


- (void)setLocationDefaults
{
	if (type == CURL_CLIENT_SFTP)
	{
		[self setProtocol:kSecProtocolTypeSSH];
		[self setPort:22];
	}
	else if (type == CURL_CLIENT_FTP)
	{
		[self setProtocol:kSecProtocolTypeFTP];
		[self setPort:21];
		[self setUsePublicKeyAuth:NO];
		[self setPrivateKeyFile:nil];
		[self setPublicKeyFile:nil];		
	}
	else if (type == CURL_CLIENT_S3)
	{
		[self setProtocol:kSecProtocolTypeHTTPS];
		[self setPort:443];
		[self setHostname:@"s3.amazonaws.com"];
		[self setDirectory:@""];
		[self setWebAccessible:YES];
		[self setUsePublicKeyAuth:NO];
		[self setPrivateKeyFile:nil];
		[self setPublicKeyFile:nil];
	}
}


- (void)guessBaseUrl
{
	if (webAccessible && ([self baseUrl] == nil || 
						  [[self baseUrl] length] == 0 || 
						  [[self baseUrl] isEqualToString:@"http://"] ||
						  [[self baseUrl] isEqualToString:[NSString stringWithFormat:@"http://%@", hostname]]))
	{
		NSString *url = @"";
		
		if ([hostname length] > 0)
		{
			url = [hostname copy];
			
			if (![[directory lastPathComponent] isEqualToString:@"~"])
			{
				url = [url stringByAppendingPathComponent:[directory lastPathComponent]];
			}			
		}
				
		[self setBaseUrl:[NSString stringWithFormat:@"http://%@", url]];
	}
}


- (NSString *)protocolString
{
	NSString *str;
	
	if (type == CURL_CLIENT_SFTP)
	{
		str = @"SFTP";
	}
	else if (type == CURL_CLIENT_FTP)
	{
		str = @"FTP";
	}
	else if (type == CURL_CLIENT_S3)
	{
		str = @"S3";
	}

	return str;
}


- (void)dealloc
{
	[hostname release], hostname = nil;
	[username release], username = nil;
	[password release], password = nil;
	[directory release], directory = nil;
	[privateKeyFile release], privateKeyFile = nil;
	[publicKeyFile release], publicKeyFile = nil;
	[uid release], uid = nil;
	
	[super dealloc];
}

@end
